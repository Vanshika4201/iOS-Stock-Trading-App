const express = require("express");
// const fetch = require('node-fetch');
const app = express();
const cors = require("cors");
app.use(cors());
const path = require("path");

app.set('trust proxy', true);


const PORT = process.env.PORT || 3000; // Use whatever port is appropriate
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});


const { MongoClient, ServerApiVersion } = require("mongodb");
const uri = "mongodb+srv://aswal:qA9x7UIlKHzXjZVZ@cluster0.xh3xrub.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true, 
    deprecationErrors: true,
  }
});
const mydbname = client.db("stockdata");

async function run() {
  try {
    // Connect the client to the server	(optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    await client.db("stockdata").command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
    const mydbname = client.db("stockdata");
  } finally {
    // Ensures that the client will close when you finish/error
    // await client.close();
  }
}
run().catch(console.dir);


// WATCHLIST

app.get('/mongowatchCheck', async (req,res) => {
  await client.connect();

  const ticker = req.query.symbol;
  const data = await mydbname.collection("userdata").findOne({ ticker: ticker });
  if (data) {
    // Send "not empty" if ticker is found
    res.json({ message: "not empty", data: data }); 
  } else {
    // Send "empty" if no ticker is found
    res.json({ message: "empty" }); 
  }
});

app.get('/mongowatchAdd', async (req,res) => {
  const tickerfetch1 = req.query.symbol;
  console.log("Added to Watchlist",tickerfetch1);
  await client.connect();
  await mydbname.collection("userdata").insertOne({ticker: tickerfetch1});
  res.json("Successfully Added"); 
});

app.get('/mongowatchRemove', async (req,res) => {
  const tickerfetch2 = req.query.symbol;
  await client.connect();
  await mydbname.collection("userdata").deleteOne({ticker: tickerfetch2});
  res.json("Successfully Removed"); 
});

app.get('/mongofetchquote', async (req,res) => {
  const quotedata = await mydbname.collection("userdata").find({}).toArray();
  console.log(quotedata);
  var watchlistdata = [];

  for(var i=0; i<quotedata.length; i++)
  {
    const apiUrl1 = `https://finnhub.io/api/v1/stock/profile2?symbol=${quotedata[i]['ticker']}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;
    const apiUrl2 = `https://finnhub.io/api/v1/quote?symbol=${quotedata[i]['ticker']}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;
    
    const data1 = await fetch(apiUrl1).then(res => res.json());
    const data2 = await fetch(apiUrl2).then(res => res.json());  
    
    data2['ticker'] = quotedata[i]['ticker'];
    data2['name'] = data1['name'];
    watchlistdata.push(data2);
    console.log(watchlistdata);
  }

  console.log("DATA FROM API",watchlistdata);
  res.json(watchlistdata);
});



// app.use(cors({
//   origin: 'http://localhost:4200' // The port where your frontend runs
// }));
// // Replace "http://localhost:4200" with the URL of your frontend
// const corsOptions = {
//   origin: 'http://localhost:4200',
// };

// app.use(cors(corsOptions));

// app.use(cors());

// app.listen(3000, () => {
//   console.log('Server running on port 3000');
// });



app.get("/stockname", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const api_url = `https://finnhub.io/api/v1/stock/profile2?symbol=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;
  // Perform the search using the query
  // This could involve a database call or an external API call
  // const results = performSearch(query);
  // res.json({ data: results });

  console.log(args);

  try {
    const response = await fetch(api_url);
    if (!response.ok) {
      throw new Error(`Error: ${response.status}`);
    }
    const data = await response.json();
    console.log(data);
    res.json(data);
  } catch (error) {
    console.error("Error fetching stock data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/stockchart", async (req, res) => {
  const args = req.query.symbol.toUpperCase();

  // Get today's date and 195 days before today
  const todayDate = new Date();
  const date731DaysBefore = new Date();
  date731DaysBefore.setDate(todayDate.getDate() - 731);

  // Format the dates as strings
  const formattedToday = todayDate.toISOString().split("T")[0];
  const formatted731DaysBefore = date731DaysBefore.toISOString().split("T")[0];

  console.log("Today's date:", formattedToday);
  console.log("195 days before today's date:", formatted731DaysBefore);

  const api_url = `https://api.polygon.io/v2/aggs/ticker/${args}/range/1/day/${formatted731DaysBefore}/${formattedToday}?adjusted=true&sort=asc&apiKey=m8IQztJ5shAgkvNxl76T5RfcqQb29hD3`;

  console.log(args);
  try {
    const response = await fetch(api_url);
    const data = await response.json();

    let ohlcdata = [];
    let voldata = [];

    if(Object.keys(data).length > 3 && data.resultsCount !== 0){
      ohlcdata = data.results.map(function(svol) {
        return [svol.t, svol.o, svol.h, svol.l, svol.c];
      });

      voldata = data.results.map(function(svol) {
        return [svol.t, svol.v];
      });
    }

    const combineddata = {
      data1: ohlcdata,
      data2: voldata
    };


    res.json(combineddata);
    console.log(combineddata);
  } catch (error) {
    console.error("Error fetching stock chart data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/stockcharthourly", async (req, res) => {
  const args = req.query.symbol.toUpperCase();

  // Get today's date and 195 days before today
  const todayDate = new Date();
  
  // const todayDate1 =new Date();

  const yesterday = new Date();
  yesterday.setDate(todayDate.getDate() - 1);

  // Format the dates as strings
  const formattedToday = todayDate.toISOString().split("T")[0];

  // const formattedToday = todayDate.toISOString().split("T")[0];
  const formattedYesterday = yesterday.toISOString().split("T")[0];

  console.log("Today's date:", formattedToday);
  console.log("Yesterday's date:", formattedYesterday);

  const api_url = `https://api.polygon.io/v2/aggs/ticker/${args}/range/1/hour/${formattedYesterday}/${formattedToday}?adjusted=true&sort=asc&apiKey=m8IQztJ5shAgkvNxl76T5RfcqQb29hD3`;

  console.log(args);
  try {
    const response = await fetch(api_url);
    const data = await response.json();
    const data1 = data['results']

    var tc = [];
    for(let i = 0; i < data1.length; i++) {
      tc.push([data1[i].t, data1[i].c]);
    }

    if(Array.isArray(tc)) {
      res.json(tc)
    } else {
      console.error(" Not an array: ", data1);
      res.status(500).json({ error: "Not desired format "});
    }
  } catch (error) {
    console.error("Error fetching stock chart data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});


app.get("/stockautocomplete", async (req, res) => {
  const args = req.query.symbol.toUpperCase();

  const apiUrl = `https://finnhub.io/api/v1/search?q=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    var data = await response.json();
    data = data['result'].filter(item => item.type === "Common Stock" && !item.symbol.includes('.'));
    res.json(data);
    console.log(data);
  } catch (error) {
    console.error("Error fetching stock autocomplete data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/stocksummary", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;


  try {
    const response = await fetch(apiUrl);
    
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();
    console.log(data);
    res.json(data);
    console.log(data);
  } catch (error) {
    console.error("Error fetching stock summary data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/stocksummaryrecommender", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const apiUrl = `https://finnhub.io/api/v1/stock/recommendation?symbol=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();

    // Uncomment below if sorting is needed:
    // const sortedData = data.sort((a, b) => new Date(b.period) - new Date(a.period));
    // const latestData = sortedData[0];
    // res.json(latestData);

    res.json(data); // Remove or comment out if using the sorting logic above
    console.log(data);
  } catch (error) {
    console.error("Error fetching stock recommendation data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/news", async (req, res) => {
  const args = req.query.symbol.toUpperCase();

  // Get today's date and 30 days before today
  const todayDate = new Date();
  const date30DaysBefore = new Date();
  date30DaysBefore.setDate(todayDate.getDate() - 30);

  // Format the dates as strings
  const formattedToday = todayDate.toISOString().split("T")[0];
  const formatted30DaysBefore = date30DaysBefore.toISOString().split("T")[0];

  console.log("Today's date:", formattedToday);
  console.log("30 days before today's date:", formatted30DaysBefore);

  const apiUrl = `https://finnhub.io/api/v1/company-news?symbol=${args}&from=${formatted30DaysBefore}&to=${formattedToday}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();

    const filteredData = data.filter(item => item.image && item.headline && item.source && item.summary && item.url).slice(0, 20);

    res.json(filteredData);
    console.log(filteredData);
  } catch (error) {
    console.error("Error fetching news data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/insidersentiment", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const from = "2022-01-01";
  const apiUrl = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${args}&from=${from}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();

    // Initialize aggregation variables
    let totalMspr = 0;
    let positiveMspr = 0;
    let negativeMspr = 0;
    let totalChange = 0;
    let positiveChange = 0;
    let negativeChange = 0;

    // Perform aggregation
    data.data.forEach(item => {
      const mspr = item.mspr || 0;
      const change = item.change || 0;

      totalMspr += mspr;
      totalChange += change;

      if (mspr > 0) {
        positiveMspr += mspr;
      } else if (mspr < 0) {
        negativeMspr += mspr;
      }

      if (change > 0) {
        positiveChange += change;
      } else if (change < 0) {
        negativeChange += change;
      }
    });

    // Prepare the response object
    const sentimentSummary = {
      totalMspr,
      positiveMspr,
      negativeMspr,
      totalChange,
      positiveChange,
      negativeChange
    };

    res.json(sentimentSummary);
    console.log(sentimentSummary);
  } catch (error) {
    console.error("Error fetching insider sentiment data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/companypeers", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const apiUrl = `https://finnhub.io/api/v1/stock/peers?symbol=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();
    res.json(data);
    console.log(data);
  } catch (error) {
    console.error("Error fetching company peers data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/earnings", async (req, res) => {
  const args = req.query.symbol.toUpperCase();
  const apiUrl = `https://finnhub.io/api/v1/stock/earnings?symbol=${args}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;

  console.log(args);

  try {
    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`Error from Finnhub API: ${response.statusText}`);
    }
    const data = await response.json();
    res.json(data);
    console.log(data);
  } catch (error) {
    console.error("Error fetching company earnings data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});


// PORTFOLIO


app.get('/portfolioAdd', async (req, res) => {
  const tickerSymbol = req.query.symbol;
  const quantityToAdd = parseFloat(req.query.quantity); // Assuming quantity is passed as a query parameter
  const totalCostToAdd = parseFloat(req.query.totalCost); // Assuming totalCost is passed as a query parameter

  console.log("Processing addition to Portfolio for", tickerSymbol);

  await client.connect();
  const collection = mydbname.collection("portfolio");

  // Check if the ticker already exists in the database
  const existingEntry = await collection.findOne({ ticker: tickerSymbol });

  if (existingEntry) {
    // If the ticker exists, calculate the new values
    const updatedQuantity = existingEntry.quantity + quantityToAdd;
    const updatedTotalCost = existingEntry.totalCost + totalCostToAdd;
    const updatedAvgCost = updatedTotalCost / updatedQuantity;

    // Update the existing document with the new values
    await collection.updateOne(
      { ticker: tickerSymbol },
      {
        $set: {
          quantity: updatedQuantity,
          totalCost: updatedTotalCost,
          avgCost: updatedAvgCost
        }
      }
    );

    res.json("Ticker updated successfully in the portfolio.");
  } else {
    console.log(totalCostToAdd);
    // If the ticker does not exist, insert it as a new document
    await collection.insertOne({
      ticker: tickerSymbol,
      quantity: quantityToAdd,
      totalCost: totalCostToAdd,
      avgCost: totalCostToAdd / quantityToAdd // Initial average cost is totalCost/quantity
    });

    res.json("Ticker added successfully to the portfolio.");
  }
    var money = mydbname.collection("wallet");
    // var money1 = await money.findOne({ ticker: tickerSymbol });
    await money.updateOne(
      {"p":"wallet"},
      { $inc: { "money": -totalCostToAdd } }
    );
});


app.get('/portfolioReduce', async (req, res) => {
  const tickerSymbol = req.query.symbol;
  const quantityToReduce = parseFloat(req.query.quantity); // Assuming quantity is passed as a query parameter
  const totalCostToReduce = parseFloat(req.query.totalCost); // Assuming totalCost is passed as a query parameter

  console.log("Processing reduction from Portfolio for", tickerSymbol);

  await client.connect();
  const collection = mydbname.collection("portfolio");
  var money = mydbname.collection("wallet");

  // Check if the ticker already exists in the database
  const existingEntry = await collection.findOne({ ticker: tickerSymbol });

  if (existingEntry) {
    // Calculate the new values
    const updatedQuantity = existingEntry.quantity - quantityToReduce;
    const updatedTotalCost = existingEntry.totalCost - totalCostToReduce;

    // Check if the updated quantity is zero or negative
    if (updatedQuantity <= 0) {
      // If quantity is zero or negative, delete the document
      await collection.deleteOne({ ticker: tickerSymbol });
      res.json("Ticker removed from the portfolio as quantity reached zero.");
    } else {
      // If the quantity is positive, update the document
      const updatedAvgCost = updatedTotalCost / updatedQuantity;

      await collection.updateOne(
        { ticker: tickerSymbol },
        {
          $set: {
            quantity: updatedQuantity,
            totalCost: updatedTotalCost,
            avgCost: updatedAvgCost
          }
        }
      );

      res.json("Ticker updated successfully in the portfolio.");

      // var money1 = await money.findOne({ ticker: tickerSymbol });
      const updateResult = await money.updateOne(
        {"p":"wallet"},
        { $inc: { "money": totalCostToReduce } }
      );
    }
  } else {
    // If the ticker does not exist, send an error response
    res.status(404).json("Ticker not found in the portfolio.");
  }
});


app.get('/portfolioList', async (req, res) => {
  
  // var portfoliodata = [];

  try {
    await client.connect();
    const collection = mydbname.collection("portfolio");

    // Find all documents in the collection
    const portfolioItems = await collection.find({}).toArray();
    var portfoliodata=[]
    // Check if the portfolio is empty
    if (portfolioItems.length === 0) {
      res.json(portfolioItems);
    } else {

      for(var i=0; i<portfolioItems.length; i++){
        const apiUrl1 = `https://finnhub.io/api/v1/stock/profile2?symbol=${portfolioItems[i]['ticker']}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;
        const apiUrl2 = `https://finnhub.io/api/v1/quote?symbol=${portfolioItems[i]['ticker']}&token=cn8t449r01qocbph6e60cn8t449r01qocbph6e6g`;
      
        const data1 = await fetch(apiUrl1).then(res => res.json());
        const data2 = await fetch(apiUrl2).then(res => res.json()); 
        portfoliodata.push({
          'name' : data1['name'],
          'currentprice': data2['c'],
          'change': data2['dp'],
          'marketvalue': portfolioItems[i]['quantity']*data2['c'],
          'ticker': portfolioItems[i]['ticker'],
          'quantity': portfolioItems[i]['quantity'],
          'avgCost' : portfolioItems[i]['avgCost'],
        });
      }
      // Send all portfolio items to the client
      res.json(portfoliodata);
    }
  } catch (error) {
    console.error("Error fetching portfolio items:", error);
    res.status(500).json("An error occurred while fetching the portfolio items.");
  }
});


// app.get('/fetchByKey', async (req, res) => {
//   const keyToCheck = req.query.symbol; // Get the key from the query parameters

//   if (!keyToCheck) {
//     return res.status(400).json("No key provided.");
//   }

//   try {
//     await client.connect();
//     const collection = mydbname.collection("portfolio");

//     // Find documents where the key exists
//     const query = {"ticker":keyToCheck};
//     // query[keyToCheck] = { $exists: true };
//     const documents = await collection.find(query).toArray();

//     if (documents.length === 0) {
//       res.json({"ticker":""});
//     } else {
//       res.json(documents);
//     }
//   } catch (error) {
//     console.error("Error fetching documents by key:", error);
//     res.status(500).json("An error occurred while fetching the documents.");
//   }
// });


app.get('/fetchByKey', async (req,res) => {
  await client.connect();

  const ticker = req.query.symbol;
  const data = await mydbname.collection("portfolio").findOne({ ticker: ticker });
  if (data) {
    // Send "not empty" if ticker is found
    res.json(data); 
  } else {
    // Send "empty" if no ticker is found
    res.json({ message: "empty" }); 
  }
});


app.get('/getmoney', async (req, res) => {
    await client.connect();
    const collection = mydbname.collection("wallet");

    // Find all documents in the collection
    const portfolioItems = await collection.find({}).toArray();
    res.json(portfolioItems);
});

// app.use(express.static(path.join(__dirname, 'dist/stock-app/browser')));

// app.get('*', (req, res) => {
//   res.sendFile(path.join(__dirname, 'dist/stock-app/browser/index.html'));
// });


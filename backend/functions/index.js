require("dotenv").config();
const functions = require("firebase-functions");
const axios = require("axios");

exports.infoChecker = functions.https.onRequest(async (req, res) => {
  const CSE_ID = process.env.CSE_ID;
  const API_KEY = process.env.API_KEY;

  console.log("Claim: ", req.body.claim);
  console.log("CSE_ID: ", CSE_ID);
  console.log("API_KEY: ", API_KEY);

  // Validate inputs
  if (!req.body.claim || !CSE_ID || !API_KEY) {
    const errorMessage = "Missing claim or config variables.";
    console.error(errorMessage);
    return res.status(400).json({ error: errorMessage });
  }

  try {
    // Step 1: Get search results using Google's Custom Search API
    const searchRes = await axios.get(
      `https://www.googleapis.com/customsearch/v1?q=${encodeURIComponent(req.body.claim)}&cx=${CSE_ID}&key=${API_KEY}`
    );

    // Extract top 5 search results
    const results = searchRes.data.items?.slice(0, 5).map((item) => ({
      title: item.title || "No title available",
      snippet: item.snippet || "No snippet available",
      url: item.link || "No URL available"
    })) || [];
    
    if (results.length === 0) {
      return res.status(200).json({
        claim: req.body.claim,
        resultLinks: [{ title: "No results found", snippet: "", url: "" }]
      });
    }    

    // Return the results in a structured format
    return res.status(200).json({
      claim: req.body.claim,
      resultLinks: results
    });

  } catch (err) {
    console.error("Error occurred:", err.message);

    if (err.response && err.response.data) {
      console.error("Full Error Response:", err.response.data);
      return res.status(500).json({
        error: "Error calling the Google Custom Search API.",
        details: err.response.data,
      });
    }

    return res.status(500).json({
      error: "An unexpected error occurred.",
      details: err.message,
    });
  }
});

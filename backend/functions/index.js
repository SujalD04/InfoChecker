const functions = require("firebase-functions");
const axios = require("axios");

exports.infoChecker = functions.https.onRequest(async (req, res) => {
  const claim = req.body.claim;
  const CSE_ID = "0795293e7c1684fbb";
  const API_KEY = "AIzaSyCnbl9bQuzLXv_53LDhBk5jJOTImkcfMjw";

  try {
    const response = await axios.get(
      `https://www.googleapis.com/customsearch/v1?q=${encodeURIComponent(claim)}&cx=${CSE_ID}&key=${API_KEY}`
    );
    const results = response.data.items.slice(0, 10).map(item => ({
      title: item.title,
      snippet: item.snippet,
      url: item.link
    }));

    res.status(200).json(results);
  } catch (error) {
    res.status(500).json({ error: "Search failed", details: error.message });
  }
});

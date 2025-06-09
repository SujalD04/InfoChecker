require("dotenv").config();
const functions = require("firebase-functions");
const axios = require("axios");

exports.infoChecker = functions.https.onRequest(async (req, res) => {
  const CSE_ID = process.env.CSE_ID;
  const SEARCH_API_KEY = process.env.API_KEY;
  const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

  console.log("Claim: ", req.body.claim);

  if (!req.body.claim || !CSE_ID || !SEARCH_API_KEY || !GEMINI_API_KEY) {
    const errorMessage = "Missing claim or config variables.";
    console.error(errorMessage);
    return res.status(400).json({ error: errorMessage });
  }

  try {
    // Fetch Google search results
    const searchRes = await axios.get(
      `https://www.googleapis.com/customsearch/v1?q=${encodeURIComponent(req.body.claim)}&cx=${CSE_ID}&key=${SEARCH_API_KEY}`
    );

    const results = searchRes.data.items?.slice(0, 5).map((item) => ({
      title: item.title || "No title available",
      snippet: item.snippet || "No snippet available",
      url: item.link || "No URL available"
    })) || [];

    if (results.length === 0) {
      return res.status(200).json({
        claim: req.body.claim,
        verdict: "unverifiable",
        explanation: "No results found to assess the claim. Please provide more context.",
        sources: []
      });
    }

    const snippets = results.map((r, i) => `${i + 1}. ${r.snippet}`).join("\n");

    //Compose Gemini prompt
    const prompt = `
      You are a fact-checking assistant.

      Given the claim: "${req.body.claim}"

      And the following sources:
      ${snippets}

      Your task is to evaluate the credibility of the claim based on the above sources. Determine whether the claim is **true**, **false**, or **unverifiable**.

      Guidelines:
      - If the claim is **true**, state that clearly, explain *why* it is true based on the sources, and provide the supporting URLs.
      - If the claim is **false**, say so, explain *why* it is false based on the evidence, and provide the links that disprove it.
      - If the claim is **unverifiable**, state that it is unverifiable based on the given sources, and 
        suggest that the user provide more details or clarify the claim for better results.

      Respond in plain text. Do not use JSON or any structured format.

      Make sure to include:
      - Verdict: true / false / unverifiable
      - Explanation
      - Sources (as plain URLs)
      `;

    // Call Gemini via Google AI Studio API
    const geminiResponse = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        contents: [
          {
            role: "user",
            parts: [{ text: prompt }]
          }
        ]
      },
      {
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": GEMINI_API_KEY
        }
      }
    );

    const geminiReply = geminiResponse.data?.candidates?.[0]?.content?.parts?.[0]?.text || "No response from Gemini.";

    // Return final output
    return res.status(200).json({
      claim: req.body.claim,
      result: geminiReply,
      resultLinks: results
    });

  } catch (err) {
    console.error("Error occurred:", err.message);

    if (err.response?.data) {
      console.error("Full Error Response:", err.response.data);
      return res.status(500).json({
        error: "An error occurred while calling external APIs.",
        details: err.response.data
      });
    }

    return res.status(500).json({
      error: "Unexpected server error.",
      details: err.message
    });
  }
});

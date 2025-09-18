import express from "express";
import { Document } from "../models/document.js";
import { auth } from "../middleware/auth.js";

const documentRouter = express.Router();

documentRouter.post("/doc/create", auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    let document = new Document({
      uid: req.user,
      title: "Untitled Document",
      createdAt: createdAt.toString(),
    });
    document = await document.save();

    const docObj = document.toObject();
    docObj.createdAt = docObj.createdAt.toString();
    res.json(docObj);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

documentRouter.get("/doc/me", auth, async (req, res) => {
  try {
    let documents = await Document.find({ uid: req.user });
    res.json(documents);
  } catch (e) {
    res.status(500).json({ error: e.meesage });
  }
});

documentRouter.post("/doc/title", auth, async (req, res) => {
  try {
    const { id, title } = req.body;
    let document = await Document.findByIdAndUpdate(id, { title });
    res.json(document);
  } catch (e) {
    res.status(500).json({ error: e.meesage });
  }
});

documentRouter.get("/doc/title/:id", auth, async (req, res) => {
  try {
    let document = await Document.findById(req.params.id);
    res.json(document);
  } catch (e) {
    res.status(500).json({ error: e.meesage });
  }
});

export { documentRouter };

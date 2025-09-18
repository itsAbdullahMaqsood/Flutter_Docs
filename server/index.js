import dotenv from "dotenv";
dotenv.config();
import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import http from "http";
import socket from "socket.io";
import { authRouter } from "./routes/auth.js";
import { documentRouter } from "./routes/document.js";

const PORT = process.env.PORT || 3001;

const app = express();
var server = http.createServer(app);
var io = socket(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

export const DB = process.env.DB_URI;

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection successful!");
  })
  .catch((error) => {
    console.log(error);
  });

io.on("connection", (socket) => {
  socket.on("join", (documentId) => {
    socket.join(documentId);
    console.log("User joined room: " + documentId);
  });

  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });
});

server.listen(process.env.PORT, "0.0.0.0", () => {
  console.log(`connected at port ${process.env.PORT}`);
  console.log(`check check`);
});

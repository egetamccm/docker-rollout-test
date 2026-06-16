const fs = require("fs");
const express = require("express");

const app = express();
const port = process.env.PORT || 3000;
const version = process.env.APP_VERSION || "v1";
const startedAt = new Date().toISOString();

app.disable("x-powered-by");

app.use((req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("X-Frame-Options", "DENY");
  next();
});

app.get("/", (req, res) => {
  res.setHeader("Content-Type", "application/json");
  res.status(200).send({
    service: "docker-rollout-demo",
    version,
    hostname: process.env.HOSTNAME || "unknown",
    startedAt,
    now: new Date().toISOString()
  });
});

app.get("/health", (req, res) => {
  // During rollout, old container is marked for draining via /tmp/drain.
  if (fs.existsSync("/tmp/drain")) {
    res.status(503).send("draining");
    return;
  }

  res.status(200).send("ok");
});

app.listen(port, () => {
  console.log(`App listening on port ${port} (${version})`);
});

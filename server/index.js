const express = require('express')
const consola = require('consola')
const fs = require('fs')
const csv = require('csv')
const { Nuxt, Builder } = require('nuxt')
const app = express()

// Import and Set Nuxt.js options
const config = require('../nuxt.config.js')
config.dev = process.env.NODE_ENV !== 'production'

async function start () {
  // Init Nuxt.js
  const nuxt = new Nuxt(config)

  const { host, port } = nuxt.options.server

  await nuxt.ready()
  // Build only in dev mode
  if (config.dev) {
    const builder = new Builder(nuxt)
    await builder.build()
  }
  app.get('/api/pull_request', function (req, res) {
    fs.createReadStream(__dirname + '/csv/pull_requests.csv')
      .pipe(csv.parse({columns: true}, function(err, data) {
          pull_requests = []
          data.forEach(pull_request => {
            // console.log({pr: pull_request.user, query: req.query.user, judge: pull_request.user === req.query.user})
            if (pull_request.user === req.query.user || req.query.user === undefined) {
              pull_requests.push(pull_request)
            }
          })
          res.send(pull_requests)
      }));
  })

  // Give nuxt middleware to express
  app.use(nuxt.render)

  // Listen the server
  app.listen(port, host)
  consola.ready({
    message: `Server listening on http://${host}:${port}`,
    badge: true
  })
}
start()

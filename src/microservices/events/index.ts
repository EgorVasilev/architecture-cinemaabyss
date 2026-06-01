import { Kafka } from 'kafkajs';

import express, { type Request, type Response, type Application } from 'express';

const app: Application = express();
const port = 8082;

app.use(express.json());

const kafka = new Kafka({ clientId: 'events-service', brokers: [process.env.KAFKA_BROKERS || ''] });
const producer = kafka.producer();

type MoviePayload = {
  movie_id: number,
  title: string,
  action: string,
  user_id?: number,
  rating?: number,
  genres?: string[],
  description?: string
}

type UserPayload = {
  user_id: number,
  username?: string,
  email?: string,
  action: string,
  timestamp: string
}

type PaymentPayload = {
  payment_id: number,
  user_id: number,
  amount: number,
  status: string,
  timestamp: string,
  method_type?: string
}

function log(timestamp: string, eventId: string, topic: string) {
  console.log(`Event has been sent: ${timestamp} - ${eventId} - to ${topic} topic`);
}

app.post('/api/events/movie', async (req: Request<{}, {}, MoviePayload>, res) => {
  const movie = req.body;
  const topic = "movie-events";

  // TODO payload validation

  try {
    const timestamp = new Date();

    const [response] = await producer.send({
      topic,
      messages: [{ key: movie.movie_id.toString(), value: JSON.stringify(movie)  }],
    });

    if (!response) {
      res.status(202).send("Not acknowladged");

      return;
    }

    const eventId = `movie-${movie.movie_id}-${movie.action}`

    res.status(201).send({
      "status": "success",
      "partition": response.partition,
      "offset": response.logStartOffset,
      "event": {
        "id": eventId,
        "type": "movie",
        "timestamp": timestamp.toISOString(),
        "payload": {}
      }
    });

    log(timestamp.toISOString(), eventId, topic);
  } catch (error) {
    res.status(500).send({error});
  }
});

app.post('/api/events/user', async (req: Request<{}, {}, UserPayload>, res) => {
  const user = req.body;
  const topic = 'user-events';

  // TODO payload validation

  try {
    const [response] = await producer.send({
      topic,
      messages: [{ key: user.user_id.toString(), value: JSON.stringify(user)  }],
    });

    if (!response) {
      res.status(202).send("Not acknowladged");

      return;
    }

    const eventId = `user-${user.user_id}-${user.action}`

    res.status(201).send({
      "status": "success",
      "partition": response.partition,
      "offset": response.logStartOffset,
      "event": {
        "id": eventId,
        "type": "user",
        "timestamp": user.timestamp,
        "payload": {}
      }
    });

    log(user.timestamp, eventId, topic);
  } catch (error) {
    res.status(500).send({error});
  }
})

app.post('/api/events/payment', async (req: Request<{}, {}, PaymentPayload>, res) => {
  const payment = req.body;
  const topic = 'payment-events';

  // TODO payload validation

  try {
    const [response] = await producer.send({
      topic,
      messages: [{ key: payment.payment_id.toString(), value: JSON.stringify(payment)  }],
    });

    if (!response) {
      res.status(202).send("Not acknowladged");

      return;
    }

    const eventId = `payment-${payment.payment_id}-${payment.status}`

    res.status(201).send({
      "status": "success",
      "partition": response.partition,
      "offset": response.logStartOffset,
      "event": {
        "id": eventId,
        "type": "payment",
        "timestamp": payment.timestamp,
        "payload": {}
      }
    });

    log(payment.timestamp, eventId, topic);
  } catch (error) {
    res.status(500).send({error});
  }
})

app.get('/api/events/health', (req, res) => {
  res.send({status: true})
})



async function startUp() {
  try {
      await producer.connect();

      app.listen(port, async () => {
        console.log(`Server running at http://localhost:${port}`);
      });
  }  catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

function shutDown() {
    console.log('Received kill signal, shutting down gracefully');

    producer.disconnect();
}

process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

startUp();
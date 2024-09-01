import express, { Application } from 'express';
import { InversifyExpressServer } from 'inversify-express-utils';
import responseTime from 'response-time';
import requestID from 'express-request-id';
import container from '@app/common/config/ioc';

import env from '@app/common/config/env';
import helmet from 'helmet';
import cors from 'cors';

export class App {
  private server: InversifyExpressServer;
  constructor() {
    //public container = defaultContainer
    this.server = new InversifyExpressServer(container, null, {
      rootPath: `${env.api_version}`
    });

    // setup server-level middlewares
    this.server.setConfig((app: Application) => {
      app.disable('x-powered-by');
      app.use(express.json());
      app.use(express.urlencoded({ extended: false }));

      // add x-response-time to headers
      app.use(responseTime());

      // add request ID header to request
      app.use(requestID());

      app.use(helmet());

      // enable cors
      app.use(cors());
    });

    /**
     * Register handlers after all middlewares and controller routes have been mounted
     */
    this.server.setErrorConfig((app: Application) => {
      // expose index endpoint
      app.get('/', (req, res) => {
        res.status(200).json({ status: 'UP' });
      });

      // register 404 route handler
      app.use((req, res, next) => {
        res.status(404).send("Whoops! Route doesn't exist.");
      });
    });
  }

  /**
   * Returns the configured Inversify express server
   */
  getServer = () => this.server;

  /**
   * Applies all routes and configuration to the server, returning the express application server.
   */
  build() {
    const app = this.server.build();
    return app;
  }
}

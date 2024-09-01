// import metadata for es7 decorators support
import 'reflect-metadata';
// allow creation of aliases for directories
import 'module-alias/register';
import http from 'http';
import env from '../common/config/env';
import { App } from './app';

const start = async () => {
    try {
      const app = new App();
      const appServer = app.getServer().build();
      const httpServer = http.createServer(appServer);
  
      httpServer.listen(env.port);
      httpServer.on('listening', () =>
        console.log('listening on port ' + env.port)
      );
    } catch (err) {
      console.error(err, 'Fatal server error');
    }
};

start();
  
process.once('SIGINT', () => {
    // const pubConnection = publisher.getConnection();
    // if (pubConnection) pubConnection.close();
});
  

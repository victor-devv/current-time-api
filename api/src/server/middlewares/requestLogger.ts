import { Request, Response, NextFunction } from 'express';
import logger from '@app/common/services/logger/logger';
import env from '@app/common/config/env';

/**
 * Skip logging requests from these user agents e.g Kuberenetes and Prometheus to
 * avoid chatter in the logs
 */
const SKIP_REQUESTS = ['kube-probe', 'Prometheus'];

/**
 * Express Middleware that logs incoming HTTP requests.
 */
export default async (req: Request, res: Response, next: NextFunction) => {
  for (const userAgent of SKIP_REQUESTS) {
    const regex = new RegExp(userAgent, 'i');
    if (regex.test(req.headers['user-agent'])) return next();
  }

  const productionOrStagingEnvironment = ['production', 'staging'].includes(
    env.app_env
  );

  let originIp;

  if (productionOrStagingEnvironment) {
    const realIP = req.headers['x-real-ip'];
    originIp = Array.isArray(realIP) ? realIP[0] : realIP;
    
    if(!originIp) originIp = req.ip;
  } else {
    originIp = req.ip;
  }

  //pass to bunyan
  logger.logAPIRequest(req);
  next();
};

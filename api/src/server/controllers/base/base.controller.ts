import { injectable } from 'inversify';
import { Response, Request } from 'express';
import HttpStatus from 'http-status-codes';
import _ from 'lodash';
import { ControllerError } from '.';
import logger from '@app/common/services/logger/logger';
import { MetricsService } from '@app/server/services';

@injectable()
export class BaseController {
  /*
   * Determines the HTTP status code of an error
   * @param err Error object
   */
  getHTTPErrorCode(err) {
    // check if error code exists and is a valid HTTP code.
    if (err.code >= 100 && err.code < 600) return err.code;
    return HttpStatus.BAD_REQUEST;
  }

  /**
   * Handles operation success and sends a HTTP response
   * @param req Express request
   * @param res Express response
   * @param data Success data
   */
  handleSuccess(req: Request, res: Response, data: any) {
    res.jSend.success(data);
    logger.logAPIResponse(req, res);
    MetricsService.record(req, res);
  }

  /**
   * Handles operation error, sends a HTTP response and logs the error.
   * @param req Express request
   * @param res Express response
   * @param error Error object
   * @param message Optional error message. Useful for hiding internal errors from clients.
   */
  handleError(
    req: Request,
    res: Response,
    err: Error,
    message?: string
  ) {
    /**
     * Useful when we call an asynchrous function that might throw
     * after we've sent a response to client
     */
    if (res.headersSent) return logger.error(err);

    /**
     * Custom class error message supercedes generic error message
     */
    if (message && (err instanceof ControllerError)) message = null;

    let error_code;
    const controller_err = <ControllerError>err;
    error_code = controller_err.error_code;


    const errorMessage = message || err.message;

    let data = null;

    res.jSend.error(data, errorMessage, this.getHTTPErrorCode(err), error_code);
    logger.logAPIError(req, res, err);
    MetricsService.record(req, res);
  }
}

import HttpStatus, {
  //BAD_REQUEST,
  NOT_FOUND,
  TOO_MANY_REQUESTS
} from 'http-status-codes';

export class ControllerError extends Error {
  code: number;
  error_code: number;
  constructor(message: string, code?: number, error_code?: number) {
    super(message);
    this.code = code || 400;
    error_code = error_code || 0;
  }
}

export class ActionNotAllowedError extends ControllerError {
  constructor(message: string) {
    super(message);
    this.code = HttpStatus.BAD_REQUEST;
  }
}

/**
 * Sets the HTTP status code to 404 `Not Found` when a queried item is not found.
 *
 */
export class NotFoundError extends ControllerError {
  constructor(message: string) {
    super(message, NOT_FOUND);
  }
}

export class InvalidUserAgentError extends ControllerError {
  constructor() {
    const errorMessage = 'invalid user-agent';
    super(errorMessage);

    this.code = HttpStatus.BAD_REQUEST;
    this.error_code = 327;
  }
}

export class TooManyRequestError extends ControllerError {
  constructor() {
    super(`You have exceeded the number requests allowed in window limit`);
    this.code = TOO_MANY_REQUESTS;
  }
}

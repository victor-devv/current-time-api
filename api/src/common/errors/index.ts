import HttpStatus, { NOT_FOUND } from 'http-status-codes';

export class ControllerError extends Error {
  code: number;
  error_code: number;
  constructor(message: string, code?: number, error_code?: number) {
    super(message);
    this.code = code || 400;
    this.error_code = error_code || 0;
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
 */
export class NotFoundError extends ControllerError {
  constructor(message: string) {
    super(message, NOT_FOUND);
  }
}

export class ForbiddenError extends ControllerError {
  constructor() {
    const errorMessage = `Forbidden!`;
    super(errorMessage);

    this.code = HttpStatus.FORBIDDEN;
    this.error_code = 706;
  }
}

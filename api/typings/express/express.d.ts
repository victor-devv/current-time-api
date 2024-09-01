import jSend from 'jsend';

declare global {
  namespace Express {
    export interface Request {
      partner: any;
      product: any;
      user: any;
      id: string;
      cit_id: any;
    }

    export interface Response {
      body: any;
      jSend: jSend;
    }
  }
}

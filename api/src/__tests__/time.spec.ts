import 'reflect-metadata';
import HTTPStatus from 'http-status-codes';
import supertest from 'supertest';
import { App } from '@app/server/app';

const BASE_URL = '/api/v1/time';

let app: App;
let request: supertest.SuperTest<supertest.Test>;

beforeAll(async () => {
  app = new App();
  request = supertest(app.build());
});

it('returns the current time', async () => {
  const { body } = await request
    .get(BASE_URL)
    .expect(HTTPStatus.OK);

  const { data, status } = body;

  expect(status).toBe('success');
  expect(data.datetime).toBeDefined();
});
import dotenv from 'dotenv';
import { isEmpty } from 'lodash';
dotenv.config();

const validEnvs = ['dev', 'production', 'staging', 'test'] as const;
type AppEnv = typeof validEnvs[number];

const getEnv = (): AppEnv => {
  return validEnvs.find((_) => _ === process.env.NODE_ENV) ?? 'dev';
};

const optionalEnvVars = {
  api_version: process.env.API_VERSION || '/api/v1',
  app_env: getEnv(),
  service_name: process.env.SERVICE_NAME || 'shortlet-current-time',
} as const;

const requiredEnvVars = {
  port: Number(process.env.PORT),
  salt_rounds: Number(process.env.SALT_ROUNDS) || 10
} as const;

const prodAndStagingVars = {

} as const;

const prodOnlyVariables = {
  
} as const;

const env = {
  ...optionalEnvVars,
  ...requiredEnvVars,
  ...prodAndStagingVars,
  ...prodOnlyVariables
} as const;

const getKeys = (obj: {}, _: { ifEnvIs: AppEnv[] }) =>
  _.ifEnvIs.includes(env.app_env) ? Object.keys(obj) : [];

const requiredVariables = Object.keys(requiredEnvVars)
  .concat(getKeys(prodAndStagingVars, { ifEnvIs: ['production', 'staging'] }))
  .concat(getKeys(prodOnlyVariables, { ifEnvIs: ['production'] }));

const missingVariables = requiredVariables
  .filter((key) => !env[key])
  .map((_) => _.toUpperCase());

if (!isEmpty(missingVariables)) {
  throw new Error(
    `The following required variables are missing: ${missingVariables}`
  );
}

export default env;

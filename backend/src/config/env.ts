export const validateEnv = () => {
  const required = ['MONGO_URI', 'JWT_SECRET', 'REFRESH_TOKEN_PEPPER'];
  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }

  if (process.env.NODE_ENV === 'production') {
    const weakSecrets = ['change_me', 'change_me_too', 'change_me_webhook'];
    const secrets = [
      process.env.JWT_SECRET,
      process.env.REFRESH_TOKEN_PEPPER,
      process.env.PAYMENT_WEBHOOK_SECRET
    ];

    for (const secret of secrets) {
      if (secret && weakSecrets.includes(secret)) {
        throw new Error('Weak secrets detected in production. Please use strong secrets.');
      }
    }
  }
};

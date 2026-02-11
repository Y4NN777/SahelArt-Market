jest.mock('../../src/services/email.service', () => ({
  EmailService: {
    send: jest.fn().mockResolvedValue(true),
    sendWelcome: jest.fn().mockResolvedValue(true),
    sendOrderConfirmation: jest.fn().mockResolvedValue(true),
    sendPaymentReceived: jest.fn().mockResolvedValue(true),
    sendOrderShipped: jest.fn().mockResolvedValue(true),
    sendOrderDelivered: jest.fn().mockResolvedValue(true)
  }
}));

import nodemailer from 'nodemailer';
import { getTransporter, getFromAddress } from '../config/email';
import {
  welcomeEmail,
  orderConfirmationEmail,
  paymentReceivedEmail,
  orderShippedEmail,
  orderDeliveredEmail
} from '../templates/email.templates';

const send = async (to: string, subject: string, html: string): Promise<boolean> => {
  try {
    const transporter = await getTransporter();
    const info = await transporter.sendMail({
      from: getFromAddress(),
      to,
      subject,
      html
    });
    const previewUrl = nodemailer.getTestMessageUrl(info);
    if (previewUrl) {
      console.log(`[Email] Preview: ${previewUrl}`);
    }
    return true;
  } catch (err) {
    console.error('[Email] Failed to send:', (err as Error).message);
    return false;
  }
};

export const EmailService = {
  send,

  async sendWelcome(to: string, firstName: string): Promise<boolean> {
    const { subject, html } = welcomeEmail(firstName);
    return send(to, subject, html);
  },

  async sendOrderConfirmation(
    to: string,
    orderId: string,
    items: { name: string; quantity: number; subtotal: number }[],
    total: number
  ): Promise<boolean> {
    const { subject, html } = orderConfirmationEmail(orderId, items, total);
    return send(to, subject, html);
  },

  async sendPaymentReceived(to: string, orderId: string, amount: number, method: string): Promise<boolean> {
    const { subject, html } = paymentReceivedEmail(orderId, amount, method);
    return send(to, subject, html);
  },

  async sendOrderShipped(to: string, orderId: string, trackingNumber?: string): Promise<boolean> {
    const { subject, html } = orderShippedEmail(orderId, trackingNumber);
    return send(to, subject, html);
  },

  async sendOrderDelivered(to: string, orderId: string): Promise<boolean> {
    const { subject, html } = orderDeliveredEmail(orderId);
    return send(to, subject, html);
  }
};

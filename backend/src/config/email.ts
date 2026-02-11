import nodemailer from 'nodemailer';
import type { Transporter } from 'nodemailer';

let transporter: Transporter | null = null;

export const getTransporter = async (): Promise<Transporter> => {
  if (transporter) return transporter;

  if (process.env.SMTP_HOST) {
    transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT || '587', 10),
      secure: process.env.SMTP_PORT === '465',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
  } else {
    const testAccount = await nodemailer.createTestAccount();
    console.log('[Email] Ethereal test account created:');
    console.log(`  User: ${testAccount.user}`);
    console.log(`  Pass: ${testAccount.pass}`);
    transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass
      }
    });
  }

  return transporter;
};

export const getFromAddress = (): string => {
  return process.env.SMTP_FROM || 'noreply@sahelart.com';
};

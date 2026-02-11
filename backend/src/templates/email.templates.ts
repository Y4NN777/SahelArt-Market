const formatXOF = (amount: number): string => {
  return `${amount.toLocaleString('fr-FR')} FCFA`;
};

const layout = (title: string, body: string): string => `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333;">
  <div style="background: #8B4513; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="color: #fff; margin: 0; font-size: 24px;">SahelArt Market</h1>
  </div>
  <div style="padding: 20px; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px;">
    <h2 style="color: #8B4513;">${title}</h2>
    ${body}
  </div>
  <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
    SahelArt Market &mdash; Artisanat du Sahel
  </p>
</body>
</html>`;

export const welcomeEmail = (firstName: string) => ({
  subject: 'Bienvenue sur SahelArt Market!',
  html: layout(
    `Bienvenue, ${firstName}!`,
    `<p>Merci de rejoindre SahelArt Market, votre plateforme pour l'artisanat du Sahel.</p>
     <p>Explorez notre collection de produits artisanaux uniques du Mali, Niger, Burkina Faso, Tchad et Sénégal.</p>
     <p>Bonne découverte!</p>`
  )
});

export const orderConfirmationEmail = (
  orderId: string,
  items: { name: string; quantity: number; subtotal: number }[],
  total: number
) => ({
  subject: `Commande confirmée — ${orderId}`,
  html: layout(
    'Commande confirmée',
    `<p>Votre commande <strong>${orderId}</strong> a été enregistrée.</p>
     <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
       <tr style="background: #f5f5f5;">
         <th style="text-align: left; padding: 8px; border-bottom: 1px solid #ddd;">Produit</th>
         <th style="text-align: center; padding: 8px; border-bottom: 1px solid #ddd;">Qté</th>
         <th style="text-align: right; padding: 8px; border-bottom: 1px solid #ddd;">Sous-total</th>
       </tr>
       ${items
         .map(
           (i) =>
             `<tr>
               <td style="padding: 8px; border-bottom: 1px solid #eee;">${i.name}</td>
               <td style="text-align: center; padding: 8px; border-bottom: 1px solid #eee;">${i.quantity}</td>
               <td style="text-align: right; padding: 8px; border-bottom: 1px solid #eee;">${formatXOF(i.subtotal)}</td>
             </tr>`
         )
         .join('')}
       <tr>
         <td colspan="2" style="padding: 8px; font-weight: bold;">Total</td>
         <td style="text-align: right; padding: 8px; font-weight: bold;">${formatXOF(total)}</td>
       </tr>
     </table>
     <p>Procédez au paiement pour finaliser votre commande.</p>`
  )
});

export const paymentReceivedEmail = (orderId: string, amount: number, method: string) => ({
  subject: `Paiement reçu — ${orderId}`,
  html: layout(
    'Paiement confirmé',
    `<p>Nous avons bien reçu votre paiement pour la commande <strong>${orderId}</strong>.</p>
     <p><strong>Montant:</strong> ${formatXOF(amount)}</p>
     <p><strong>Méthode:</strong> ${method}</p>
     <p>Votre commande sera préparée et expédiée prochainement.</p>`
  )
});

export const orderShippedEmail = (orderId: string, trackingNumber?: string) => ({
  subject: `Commande expédiée — ${orderId}`,
  html: layout(
    'Commande expédiée',
    `<p>Votre commande <strong>${orderId}</strong> a été expédiée!</p>
     ${trackingNumber ? `<p><strong>Numéro de suivi:</strong> ${trackingNumber}</p>` : ''}
     <p>Vous recevrez une notification à la livraison.</p>`
  )
});

export const orderDeliveredEmail = (orderId: string) => ({
  subject: `Commande livrée — ${orderId}`,
  html: layout(
    'Commande livrée',
    `<p>Votre commande <strong>${orderId}</strong> a été livrée.</p>
     <p>Merci pour votre achat sur SahelArt Market!</p>`
  )
});

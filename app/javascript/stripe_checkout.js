document.addEventListener("turbo:load", function() {
  const stripeKey = document.querySelector('meta[name="stripe-public-key"]')?.content;
  if (!stripeKey) {
    console.error("Stripe public key not found in meta tag.");
    return;
  }

  const stripe = Stripe(stripeKey);

  const btn = document.getElementById("checkout-button");
  if (!btn) {
    return;
  }

  btn.addEventListener("click", async (e) => {
    e.preventDefault();

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    if (!csrfToken) {
      alert("CSRF token not found");
      return;
    }

    try {
      const resp = await fetch("/cart/create_checkout_session", {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ cart_id: btn.dataset.cartId })
      });

      const data = await resp.json();
      if (resp.status !== 200) {
        throw new Error(data.error || `Status ${resp.status}`);
      }

      await stripe.redirectToCheckout({ sessionId: data.sessionId });

    } catch (err) {
      console.error("Checkout error:", err);
      alert(`Payment setup failed: ${err.message}`);
    }
  });
});

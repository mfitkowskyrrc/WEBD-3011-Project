document.addEventListener("DOMContentLoaded", function () {
  const stripe = Stripe("<%= ENV['STRIPE_PUBLIC_KEY'] %>");

  const checkoutButton = document.getElementById("checkout-button");

  checkoutButton.addEventListener("click", function (event) {
    event.preventDefault();

    fetch("<%= create_checkout_session_cart_path %>", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        cart_id: "<%= @cart.id %>",
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        return stripe.redirectToCheckout({ sessionId: data.sessionId });
      })
      .then((result) => {
        if (result.error) {
          alert(result.error.message);
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("An error occurred. Please try again.");
      });
  });
});

document.addEventListener("DOMContentLoaded", function () {
  const stripe = Stripe("your-publishable-key-here");
  const elements = stripe.elements();
  const cardElement = elements.create("card");
  cardElement.mount("#card-element");

  const checkoutButton = document.getElementById("checkout-button");

  checkoutButton.addEventListener("click", function (event) {
    event.preventDefault();

    fetch("/carts/create_checkout_session", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        cart_id: "<%= @cart.id %>",
      }),
    })
      .then((response) => response.json())
      .then((sessionId) => {
        return stripe.redirectToCheckout({ sessionId: sessionId });
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

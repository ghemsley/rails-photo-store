const SnipcartListener = () => {
  console.log(document.cookie)
  console.log(sessionStorage)
  document.addEventListener('snipcart.ready', () => {
    Snipcart.events.on('customer.signedin', (customer) => {
      console.log(customer)
      console.log(`Customer ${customer.email} just signed in.`)
      // let formData = new FormData()
      // let token = document
      //   .querySelector('meta[name="csrf-token"]')
      //   .getAttribute('content')
      // formData.append('authenticity_token', token)
      // formData.append('user[email]', customer.email)

      // fetch('/signin', { method: 'POST', body: formData })
      //   .then((response) => {
      //     console.log(response)
      //   })
      //   .catch((error) => {
      //     console.log(error)
      //   })
    })
    Snipcart.events.on('customer.registered', (customer) => {
      console.log(customer)
      console.log(`Customer ${customer.email} just registered.`)

      // let formData = new FormData()
      // let token = document
      //   .querySelector('meta[name="csrf-token"]')
      //   .getAttribute('content')
      // formData.append('authenticity_token', token)
      // formData.append('user[email]', customer.email)

      // fetch('/users', { method: 'POST', body: formData })
      //   .then((response) => {
      //     console.log(response)
      //   })
      //   .catch((error) => {
      //     console.error(error)
      //   })
    })

    Snipcart.events.on('customer.signedout', () => {
      console.log('Customer signed out')
      // fetch('/signout', { method: 'GET' })
      //   .then((response) => {
      //     console.log(response)
      //   })
      //   .catch((error) => {
      //     console.error(error)
      //   })
    })
    Snipcart.events.on('cart.confirm.error', (confirmError) => {
      console.log(confirmError)
      confirmError.data.forEach((item) => {
        console.log(item)
      })
    })
    Snipcart.events.on('cart.confirmed', (cartConfirmResponse) => {
      console.log(cartConfirmResponse)
    })
  })
}

export default SnipcartListener

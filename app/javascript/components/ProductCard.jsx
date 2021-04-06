import React, { useState } from 'react'
import Lightbox from 'react-awesome-lightbox'
import 'react-awesome-lightbox/build/style.css'

const disable = (event) => {
  event.preventDefault()
}

const ProductCard = (props) => {
  const json = JSON.parse(props.dimensions_json)
  const [open, setOpen] = useState(false)
  const [selected, setSelected] = useState(json[0].distances_string)
  const [loaded, setLoaded] = useState(false)
  const [price, setPrice] = useState(0)
  const urlRegex = new RegExp(/\/products\/\d+$/i)
  window.addEventListener('load', (event) => {
    setLoaded(true)
  })
  if (open) {
    window.addEventListener('contextmenu', disable)
  } else {
    window.removeEventListener('contextmenu', disable)
  }

  return (
    <div className={`product-card shadow  corner-rounded ${props.class_name}`}>
      <h2 className='product-title center'>
        <a href={props.url}>{props.name}</a>
      </h2>
      <div
        className={`product-image-container${
          props.full_size ? ' full-size' : ''
        }`}
      >
        <img
          src={
            urlRegex.test(window.location.href)
              ? props.thumbnail_large
              : props.thumbnail
          }
          className={`product-image pure-img`}
          onClick={() => {
            if (props.lightbox) {
              setOpen(true)
            }
          }}
          onContextMenu={(event) => {
            event.preventDefault()
            return false
          }}
          onDragStart={(event) => {
            event.preventDefault()
            return false
          }}
        />
      </div>
      {open && (
        <Lightbox
          image={props.image}
          title={props.name}
          onClose={() => {
            setOpen(false)
          }}
        />
      )}
      {props.show_description && (
        <>
          <div className='product-description-container'>
            <p className='tiny-text'>click image to see full size</p>
            <p className='product-description'>{props.description}</p>
          </div>

          <div className='price-cart-button-container'>
            <form className='pure-form margin-vertical-1'>
              <label>Sizes available: </label>
              <select
                id='size-select-dropdown'
                value={selected}
                onChange={(event) => {
                  setSelected(event.currentTarget.value)
                  json.forEach((dimension, i) => {
                    if (
                      dimension.distances_string == event.currentTarget.value
                    ) {
                      setPrice(dimension.price_modifier)
                    }
                  })
                }}
              >
                {json.map((dimension, i) => {
                  return (
                    <option key={i} value={dimension.distances_string}>
                      {dimension.distances_string}
                    </option>
                  )
                })}
              </select>
            </form>
            <p className='margin-0 padding-0 price-blurb'>{`Price: $${(
              parseFloat(props.price) + parseFloat(price)
            ).toFixed(2)}`}</p>
            {loaded && (
              <>
                <br />
                <a
                  className='cart-button pure-button button-success center'
                  href={`https://ghemsleyphotos.foxycart.com/cart?name=${props.name.replace(
                    ' ',
                    '+'
                  )}&price=${props.price}&image=${props.thumbnail}&url=${
                    props.url
                  }&code=${props.id}&size=${document
                    .getElementById('size-select-dropdown')
                    .value.split(' ')
                    .join('%20')}{p+${
                    json.find(
                      (dimension) => dimension.distances_string == selected
                    ).price_modifier
                  }}`}
                >
                  Add to cart
                </a>
              </>
            )}
          </div>
        </>
      )}
      {!props.show_description && (
        <div className='price-cart-button-container'>
          <br />
          <a
            className='cart-button pure-link pure-button button-success center'
            href={props.url}
          >
            View product
          </a>
        </div>
      )}
    </div>
  )
}

export default ProductCard

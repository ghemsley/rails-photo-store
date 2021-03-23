import React, { useState } from 'react'
import { hot } from 'react-hot-loader'
import Lightbox from 'react-awesome-lightbox'
import 'react-awesome-lightbox/build/style.css'

const disable = (event) => {
  event.preventDefault()
}

const empty = (object) => {
  if (
    object != undefined &&
    object != null &&
    object != '' &&
    object != {} &&
    object != []
  ) {
    return false
  } else {
    return true
  }
}

const ProductCard = (props) => {
  if (props.dimensions_json) {
    var json = JSON.parse(props.dimensions_json)
  }
  const [open, setOpen] = useState(false)
  if (open) {
    window.addEventListener('contextmenu', disable)
  } else {
    window.removeEventListener('contextmenu', disable)
  }

  return (
    <div className={`product-card shadow  corner-rounded ${props.class_name}`}>
      <h1 className='product-title center'>
        <a href={props.url}>{props.name}</a>
      </h1>
      <div
        className={`product-image-container${
          props.full_size ? ' full-size' : ''
        }`}
      >
        <img
          src={props.image}
          srcSet={`${props.thumbnail} 640w, ${props.thumbnail_medium} 1080w, ${props.image} 1440w`}
          sizes='(max-width: 640px) 640px,
                 (max-width: 1080px) 1080px,
                 1440px'
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
        <div className=''>
          <p className='tiny-text'>click image to see full size</p>
          <p>{props.description}</p>
        </div>
      )}
      {json && !empty(json) ? (
        <div className='price-cart-button-container'>
          <p className='price-blurb'>{`Price: Starts at $${parseFloat(
            props.price
          ).toFixed(2)}`}</p>
          {props.show_description && (
            <>
              <p>Sizes available:</p>
              {json.map((dimension, i) => {
                return <p key={i}>{`${dimension.distances_string}`}</p>
              })}
            </>
          )}
          <button
            className='snipcart-add-item cart-button pure-button button-success center'
            data-item-id={props.id}
            data-item-price={props.price}
            data-item-url={props.url}
            data-item-description={props.description}
            data-item-image={props.image}
            data-item-name={props.name}
            data-item-stackable='never'
            data-item-custom1-name='Size'
            data-item-custom1-options={`${json.map((dimension, i) => {
              if (i + 1 == json.length) {
                return `${dimension.distances_string}[+${dimension.price_modifier}]`
              } else {
                return `${dimension.distances_string}[+${dimension.price_modifier}]|`
              }
            })}`.replace(',', '')}
          >
            Add to cart
          </button>
        </div>
      ) : (
        <div className='price-cart-button padding-1'>
          <p className='price-blurb'>{`Price: $${parseFloat(
            props.price
          ).toFixed(2)}`}</p>
          <div className='price-cart-button-container'>
            <button
              className='snipcart-add-item cart-button pure-button button-success center'
              data-item-id={props.id}
              data-item-price={props.price}
              data-item-url={props.url}
              data-item-description={props.description}
              data-item-image={props.image}
              data-item-name={props.name}
            >
              Add to cart
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default hot(module)(ProductCard)

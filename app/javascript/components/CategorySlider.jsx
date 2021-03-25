import React from 'react'
import Slider from 'react-slick'
import { hot } from 'react-hot-loader'
import ProductCard from './ProductCard'
import 'slick-carousel/slick/slick.css'
import 'slick-carousel/slick/slick-theme.css'

const CategorySlider = (props) => {
  let settings = {
    arrows: props.arrows,
    dots: props.dots,
    infinite: props.infinite,
    speed: props.speed,
    slidesToShow: props.slides_to_show,
    slidesToScroll: props.slides_to_scroll,
    autoplay: props.autoplay,
    lazyLoad: props.lazy,
    adaptiveHeight: true,
    responsive: [
      {
        breakpoint: 1440,
        settings: {
          slidesToShow: 3,
          slidesToScroll: 1,
        }
      },
      {
        breakpoint: 1080,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1,
        }
      },
      {
        breakpoint: 720,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1
        }
      }
    ]
  }
  let json = JSON.parse(props.json)
  return (
    <Slider {...settings}>
      {json.map((product, i) => {
        return (
          <ProductCard
            key={i}
            id={product.id}
            name={product.name}
            show_description={props.description}
            description={product.description}
            price={product.price}
            price_unit={product.price_unit}
            url={product.url}
            image={product.image}
            dimensions_json={product.dimensions_json}
            lightbox={product.lightbox}
            class_name='padding-1 margin-1 background-white corner-rounded'
          />
        )
      })}
    </Slider>
  )
}

export default hot(module)(CategorySlider)

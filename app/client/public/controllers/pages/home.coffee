HomePageCtrl = ($rootScope, $state, User, user, Shop) ->
  vm = this
  vm.user = user
  vm.name = 'cashback'
  vm.shops = []

  Shop.getLanding({limit: 8}).$promise.then (res) ->
    vm.shops = res

  if $state.current.name == "pages.home"
    $(document).ready( ->
      
      # $('#page-header').hide()
      $('#landing-header').show()

     
      if !$(".header-slider").hasClass('slick-initialized')
        console.log "init slider"
        $(".header-slider").slick()
        
        $('.header-slider').on('afterChange', ->
          currentSlide = $('.header-slider').slick('slickCurrentSlide')
          if (currentSlide == 0)
            $('.slick-prev,.slick-next').removeClass('white')
            $('.slick-prev').hide()
            $('.slick-next').show()
          else if (currentSlide == 1 || currentSlide == 2 )
            $('.slick-prev,.slick-next').addClass('white')
            $('.slick-prev').show()
            $('.slick-next').show()
        )


        $(".feedback-slider").slick(
            arrows: false
            autoplay: false
            autoplaySpeed: 3000
            dots: true
            focusOnSelect: true
        )
        # Управление стрелками слайдера в хедере
        currentSlide = $('.header-slider').slick('slickCurrentSlide')
        if (currentSlide == 0)
          $('.slick-prev').hide()

        # # Menu top_nav_button
        # $(".top_nav_button").click( ->
        #   $("header .visible-1400.second-nav ul").slideToggle()
        # )

        # Slider content animations
        $('header .slide-img1 .title').one('webkitAnimationEnd mozAnimationEnd
          MSAnimationEnd oanimationend animationend',
          ->
            $('header .slide-img1 ul.animated').css('visibility', 'visible')
            $('header .slide-img1 ul.animated').addClass('fadeInUp')
        )

        $('header .slide-img1 ul.animated').one('webkitAnimationEnd mozAnimationEnd
          MSAnimationEnd oanimationend animationend',
          ->
            $('header .slide-img1 .activate').addClass('visible')
            $('header .slide-img1 .animation-delay ').addClass('fadeInUp')
        )

        $('header .slide-img1 .animation-delay').one('webkitAnimationEnd mozAnimationEnd
          MSAnimationEnd oanimationend animationend',
          ->
            $('header .slide-img1 .animation-delay ').addClass('fadeInUp')
            $('.header-slider .slide-img1 .hand').addClass('visible')
        )

    )

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  return

HomePageCtrl.$inject = ['$rootScope', '$state', 'User', 'user', 'Shop']

module.exports = HomePageCtrl
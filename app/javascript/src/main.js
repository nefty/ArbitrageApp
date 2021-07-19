$(document).ready(function(){
  $(".inner-list").hide()

  $(".currency").click(function() {
    $(this).siblings().slideToggle("slow")
  })
});

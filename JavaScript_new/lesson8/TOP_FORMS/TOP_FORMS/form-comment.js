const commentForm = document.querySelector('.form__comment');
const emailInput = document.querySelector('.comment-email-input')
const emailError = document.querySelector('.comment-email-input-error')
const phoneError = document.querySelector('.comment-phone-input-error')
const phoneInput = document.querySelector('.comment-phone-input')
const messageError = document.querySelector('.comment-message-textarea-error')
const messageInput = document.querySelector('.comment-message-textarea')
const EMAIL_REGEXP = /^(([^<>()[\].,;:\s@"]+(\.[^<>()[\].,;:\s@"]+)*)|(".+"))@(([^<>()[\].,;:\s@"]+\.)+[^<>()[\].,;:\s@"]{2,})$/iu;


phoneInput.addEventListener('input', function (e){
    phoneInput.value = phoneInput.value.replace(/[^0-9.]/g, '')
})
phoneInput.onfocus = function (){
    phoneError.textContent = ' '
}
emailInput.onfocus = function (){
    emailError.textContent = ' '
}

IMask(
    document.querySelector('.comment-phone-input'),
    {
      mask: '+{7}(000)000-00-00'
    }
  )


const isEmailValid = (value) => {
    return EMAIL_REGEXP.test(value);
}

commentForm.addEventListener('submit', (event) => {
    event.preventDefault() 

    if(
        emailInput.value &&
        emailInput.value !== '' &&
        emailInput.value !== ' ' &&
        emailInput.value !== null &&
        isEmailValid(emailInput.value)
    ) { console.log('All okey') }
    else{ emailError.textContent = 'Введите email' }

    if(
        phoneInput.value &&
        phoneInput.value !== '' &&
        phoneInput.value !== ' ' &&
        phoneInput.value !== null &&
        phoneInput.value.length <= 15
    ){ console.log('All okey') }
    else{ passwordError.textContent = 'Введите Пароль' }
})
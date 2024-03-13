// const formElement = document.querySelector('.callback-form')
//
// formElement.addEventListener('submit', (e) => {
//     e.preventDefault()
//     let messages = []
//     let formData = new FormData(formElement)
//     if(formData.get('user-name') === '' || formData.get('user-name') === ' ' || formData.get('user-name') === null){
//         document.querySelector('.name-error').textContent = 'Name is required'
//     }
// })
//
// const phoneInput = document.querySelector('.phone')
//
// // IMask(
// //     document.querySelector('.phone'),
// //     {
// //         mask: '+{7}(000)000-00-00'
// //     }
// // )
//
// function phonenumber(inputtxt)
// {
//     let phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
//     if(inputtxt.value.match(phoneno)){
//         return true;
//     }
//     else
//     {
//         alert("message");
//         return false;
//     }
// }
//
// phonenumber(phoneInput)
const callPopUp   = document.querySelector('.call-popup')
const modalWindows = document.querySelector('.modal')
const modalWindow = document.querySelector('.modal-box')

callPopUp.addEventListener('click', () => {
    modalWindows.classList.add('open')

    objElement = document.createElement('p');
    objElement.class = "modal-box__title";
    objElement.innerHTML = "Apple CallBack"
    modalWindow.append(objElement);

    objNameElement = document.createElement('input');
    objNameElement.type = "text"
    objNameElement.name = "user-name"
    objNameElement.class = "modal-box__user-name"
    objNameElement.placeholder = "Enter your name"
    modalWindow.append(objNameElement);

    objPhoneElement = document.createElement('input');
    objPhoneElement.type = "text"
    objPhoneElement.name = "user-phone"
    objPhoneElement.class = "modal-box__user-phone"
    objPhoneElement.placeholder = "Enter your phone"
    modalWindow.append(objPhoneElement);

    objButtonElement = document.createElement('button');
    objButtonElement.class = "class"
    objButtonElement.name = "modal-box__send-btn"
    objButtonElement.innerHTML = "Send"
    modalWindow.append(objButtonElement);
})
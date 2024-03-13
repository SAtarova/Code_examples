//Переменная для обращения к форме регистрации по уникальному классу form-register
const registerForm = document.querySelector('.form-register');

//Функция изменения тайтла в зависимости от авторизации пользователя
//Код запустится только в том случае, когда будет загружен контент на странице
//Т.е. построится DOM дерево
window.addEventListener('DOMContentLoaded', ()=>{
    //Если в локалсторадж userData ключ userData выполняем код
    if(localStorage.getItem('userData')){
        //поместим данные из локал сторадж в переменную
        //поскольку это объект, необходимо преобразовать его из строки в объект
        //при помощи JSON.parse()
        let registerData = JSON.parse(localStorage.getItem('userData'))
        //в теге р с классом title передаем надпись Hello и имя пользователя через переменную
        document.querySelector('.title').textContent = `Hello mr. ${registerData.name}`
    }else{
        //Выводим стандратный текст
        document.querySelector('.title').textContent = `SignIn please`
    }
})


//На форму регистрации навешиваем событие submit
registerForm.addEventListener('submit', (e) => {
    //Удаляем стандартное поведение (перезагрузка страницы)
    e.preventDefault();
    //Создаем переменную, которая будет хранить в себе поля формы (данные)
    const formDataInfo = new FormData(registerForm)
    //Проводим проверку похожести пароля и повторения пароля
    //Если пароли разные выводм сообщение
    if(formDataInfo.get('user-password') !== formDataInfo.get('user-password-next')){
        //Сообщение если пароли разные
        alert('Wrong passwords!');
        //Очистка формы (очистка полей)
        registerForm.reset();
    }
    
    //Если все хорошо, в localStorage при помощи метода setItem создаем новый экземпляр
    //Первым аргументом прописываем его название, в данном случае userData
    //Второй аргумент данные которые хотим поместить, в данном случае это объект 
    //{
    //     userName:   formDataInfo.get('user-name'), 
    //     userPass:   formDataInfo.get('user-password'),
    //     userSignIn: false
    // }
    //поскольку это объект, необходимо преобразовать его в строку, при помощи метода 
    //JSON.stringify()
    localStorage.setItem('userData', JSON.stringify({
        userName:   formDataInfo.get('user-name'), 
        userPass:   formDataInfo.get('user-password')
    }
    ))
    //Очистка формы (очистка полей)
    registerForm.reset();
})


/*
Реализовать функционал формы авторизации
*/

//Авторизация пользователя 
//Обращаемся к форме авторизации по уникальному классу формы, в данном случае класс формы login-form
const loginForm = document.querySelector('.login-form')
//На форму регистрации навешиваем событие submit
loginForm.addEventListener('submit', (e) => {
    //Удаляем стандартное поведение (перезагрузка страницы)
    e.preventDefault()
    //Создаем переменную, которая будет хранить в себе поля формы логина(данные)
    const formDataInfo = new FormData(loginForm)
    //Создаем переменную, которая будет в себе хранить данные из localStorage
    //Данные в переменную помещаются за счет применения метода JSON.parse()
    //поскольку в локал сторадж данные хранятся в виде строки, а нам нужно преобразовать их в объект
    const userLocal = JSON.parse(localStorage.getItem('userData'))
    //Проведем проверку корректности логина и пароля
    if(formDataInfo.get('login-name') !== userLocal.userName || formDataInfo.get('login-password') !== userLocal.userPass){
        alert('Error');
        //Очищаем поля формы
        formDataInfo.reset();
    }else{
        //Выводим приветственное сообщение
        alert(`Hello mr. ${formDataInfo.get('login-name')}`)
        //Прописываем новый тайтл с именем
        document.querySelector('.title').textContent = `Hello mr. ${formDataInfo.get('login-name')}`;
        //Очищаем поля формы
        e.target.reset()
    }

})

//Кнопка выхода
document.querySelector('.log-out').addEventListener('click', () => {
    localStorage.removeItem('userData');
    //Выводим стандратный текст
    document.querySelector('.title').textContent = `SignIn please`;
})
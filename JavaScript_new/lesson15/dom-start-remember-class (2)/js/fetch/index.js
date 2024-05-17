const reEmail = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;
const reName = /^[a-zA-Z]+$/;
const rePhone = /^[0-9]+$/;
const objParentForm = document.querySelector('.fetch__form')
const objAllUsersButton = document.querySelector('.all-users')
const objUsersForm = document.querySelector('.fetch__users')

function CheckInput(inputData, reValue, nameOfData) {
    if (!inputData.match(reValue)) {
        alert('Input data for ' + nameOfData + ' is incorrect')
    }
}

for (let inputValue of ['name', 'email', 'phone']) {
    let reValue = ''

    switch (inputValue) {
        case 'name':
            reValue = reName;
            break;        
        case 'email':
            reValue = reEmail;
            break;        
        case 'phone': 
            reValue = rePhone;
            break;        
    }
    objParentForm.querySelector('input[name="user-' + inputValue + '"]').addEventListener('change', (e) => {
        CheckInput(e.target.value, reValue, inputValue)
    })
}

function FormTagsIntoHTML(listData) {
    let newUserTags = ``
    if (listData.length == 1) {
        insertStyle = 'afterbegin'
    }
    else insertStyle = 'beforeend'

    console.log(listData)

    for (let i of listData.data) {
        console.log(i)
        newUserTags += `<li class="fetch__users-single">
                            <p class="fetch__users-single-info fetch__users-single-info_name">${i['name']}</p>
                            <p class="fetch__users-single-info fetch__users-single-info_email">${i['email']}</p>
                            <p class="fetch__users-single-info fetch__users-single-info_phone">${i['phone']}</p>
                        </li>`}
    objUsersForm.insertAdjacentHTML(insertStyle, newUserTags)
}

objParentForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const formData = new FormData(objParentForm);    

    if (formData.get('user-name').length < 2 || formData.get('user-email').length < 2 || formData.get('user-phone').length < 2) {
        alert('Some inputs are empty')
    }

    fetch('http://make-run-now.ru/v35/create-user', {
        method: 'POST',
        body: JSON.stringify({
            name: formData.get('user-name'),
            email: formData.get('user-email'),
            phone: formData.get('user-phone'),
        })
    })
        .then(res => res.json())
        .then(data => {
            fetch('http://make-run-now.ru/v35/users', { method: 'GET' })
                .then((res) => res.json())
                .then((result) => {
                    localStorage.setItem('users', JSON.stringify({
                        userName:  formData.get('user-name'),
                        userEmail: formData.get('user-email'),
                        userPhone: formData.get('user-phone')                    
                    })
                    )
                    console.log('Current user')
                    const allData = result.data
                    console.log(result)
                    FormTagsIntoHTML([allData[allData.length - 1]])
                    console.log('-----------------------')
                });

            let currentUser = JSON.parse(localStorage.getItem('users'))            
        })  
    //objParentForm.reset()
})

objAllUsersButton.addEventListener('click', (e) => {

    fetch('http://make-run-now.ru/v35/users', { method: 'GET' })
        .then((res) => res.json())
        .then((result) => FormTagsIntoHTML(result))

})

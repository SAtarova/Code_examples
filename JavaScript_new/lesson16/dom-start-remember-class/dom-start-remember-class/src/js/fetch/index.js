const objParentForm = document.querySelector('.fetch__form')
const objAllUsersButton = document.querySelector('.all-posts')
const objUsersForm = document.querySelector('.fetch__posts')
let newUserTags = ``

function FormTagsIntoHTML(objectData) {
    objectData.forEach(item => {
        newUserTags = `<li class="fetch__users-single">
                            <p class="fetch__form-input fetch__form-input_name">${item.title}</p>
                            <p class="fetch__form-input fetch__form-input_email">${item.body}</p>
                            <p class="fetch__form-input fetch__form-input_phone">${item.author}</p>
                        </li>`
        objUsersForm.insertAdjacentHTML('beforeend', newUserTags)
    })
}

objParentForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const formData = new FormData(objParentForm);    

    if (formData.get('title').length < 2 || formData.get('body').length < 2 || formData.get('author').length < 2) {
        alert('Some inputs are empty')
    }

    fetch('http://make-run-now.ru/v35/create-user', {
        method: 'POST',
        body: JSON.stringify({
            name: formData.get('title'),
            email: formData.get('body'),
            phone: formData.get('author'),
        })
    })
        .then(res => res.json())
        .then(data => {
            fetch('http://make-run-now.ru/v35/users', { method: 'GET' })
                .then((res) => res.json())
                .then((result) => {
                    localStorage.setItem('users', JSON.stringify({
                        userName: formData.get('title'),
                        userEmail: formData.get('body'),
                        userPhone: formData.get('author')
                    })
                    )
                    let currentUser = JSON.parse(localStorage.getItem('users'))
                    newUserTags = `<li class="fetch__users-single">
                            <p class="fetch__form-input fetch__form-input_name">${currentUser.userName}</p>
                            <p class="fetch__form-input fetch__form-input_email">${currentUser.userEmail}</p>
                            <p class="fetch__form-input fetch__form-input_phone">${currentUser.userPhone}</p>
                        </li>`
                    objUsersForm.insertAdjacentHTML('afterbegin', newUserTags)
                });

            
        })  
    objParentForm.reset()
})

objAllUsersButton.addEventListener('click', (e) => {

    fetch('http://make-run-now.ru/v35/users', {method: 'GET'})
        .then((res) => res.json())
        .then((result) => {
            objUsersForm.innerHTML = ' '
            FormTagsIntoHTML(result.data)
            })

})

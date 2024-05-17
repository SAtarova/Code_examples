const plusBtn = document.querySelector('.increase-btn');
const minusBtn = document.querySelector('.decrease-btn');
const valueM = document.querySelector('.increase-decrease');

plusBtn.addEventListener('click', (e) => {
    if (valueM.value < 10) {
        valueM.value++;
    } else {
        alert("Предел");
    }
})

minusBtn.addEventListener('click', (e) => {
    if (valueM.value > 0) {
        valueM.value--;
    } else {
        alert("Предел");
    }
})

/////////////////////////////////////////////

const inputComms = [...document.querySelectorAll('.form-comment-input')];
const sendBtnComm = document.querySelector('.form-comment-button');

let commentArray = [];

sendBtnComm.addEventListener('click', () => {
    if (inputComms.some(item => item.value === '' || item.value === ' ')) {
        alert('Заполните все поля!')
    } else {

        commentArray.push({
            id: commentArray.length + 1,
            title: inputComms[0].value,
            body: inputComms[1].value,
            rating: inputComms[2].value,
            author: inputComms[3].value
        })
    }
    console.log(commentArray);
    inputComms.forEach(item => item.value = '')
});

/////////////////////////////////////////////////

const inputComments = [...document.querySelectorAll('.comment-form-input')];
const sendButton = document.querySelector('.comment-form-button');

let newComsArr = [];

sendButton.addEventListener('click', () => {
    if (inputComments.some(item => item.value === '' || item.value === ' ')) {
        alert('Заполните все поля!')
    } else {
        newComsArr.push({
            id: newComsArr.length + 1,
            title: inputComments[0].value,
            body: inputComments[1].value.length > 55 ? inputComments[1].value.slice(0, 55) + '...' : inputComments[1].value,
            rating: newComsArr.some(item => item.author === inputComments[3].value) ? '5' : inputComments[2].value,
            author: inputComments[3].value
        })
        inputComments.forEach(item => item.value = '')
        console.log(newComsArr);
    }
    let newComment = `
            <div class="comment">
                    <p class="comment-title">${newComsArr[newComsArr.length - 1].title}</p>
                    <p class="comment-body">${newComsArr[newComsArr.length - 1].body}</p>
                    <div class="comment-info">
                        <p class="comment-id">Id: ${newComsArr[newComsArr.length - 1].id}</p>
                        <p class="comment-id">Rating: ${newComsArr[newComsArr.length - 1].rating}</p>
                        <p class="comment-author">${newComsArr[newComsArr.length - 1].author}</p>
                    </div>
                </div>`
    document.querySelector('.comments').insertAdjacentHTML('beforeend', newComment)
})


/////////////////////////////////////////////////////////

const newsArray = [
    {
        userId: 1,
        id: 1,
        title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        author: 'Alex',
        body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
    },
    {
        userId: 2,
        id: 2,
        title: "qui est esse",
        author: 'Anna',
        body: "est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque fugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis qui aperiam non debitis possimus qui neque nisi nulla"
    },
    {
        userId: 3,
        id: 3,
        title: "ea molestias quasi exercitationem repellat qui ipsa sit aut",
        author: 'Nina',
        body: "et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel accusantium quis pariatur molestiae porro eius odio et labore et velit aut"
    },
    {
        userId: 1,
        id: 4,
        title: "eum et est occaecati",
        author: 'Alex',
        body: "ullam et saepe reiciendis voluptatem adipisci sit amet autem assumenda provident rerum culpa quis hic commodi nesciunt rem tenetur doloremque ipsam iure quis sunt voluptatem rerum illo velit"
    },
];

const getPosts = document.querySelector('.get-posts');
const sortPosts = document.querySelector('.sort-title');
const removePosts = document.querySelector('.delete-all');
const news = document.querySelector('.news');
const selectPosts = document.querySelector('.select-name');

getPosts.addEventListener('click', () => {
    newsArray.forEach(item => {
        let newPost = `
            <article class="post">
                <p class="post-title">${item.title}</p>
                <p class="post-body">${item.body}</p>
                <p class="post-author">Author: ${item.author}</p>
            </article>
        `;
        news.insertAdjacentHTML('beforeend', newPost);
    })
})

removePosts.addEventListener('click', () => {
    news.innerHTML = '';
})

selectPosts.addEventListener('change', () => {
    news.innerHTML = '';
    newsArray.filter(item => item.author === selectPosts.value)
        .forEach(item => {
            let newPost = `
            <article class="post">
                <p class="post-title">${item.title}</p>
                <p class="post-body">${item.body}</p>
                <p class="post-author">Author: ${item.author}</p>
            </article>
        `;
            news.insertAdjacentHTML('beforeend', newPost);
        })
})

sortPosts.addEventListener('click', () => {
    newsArray.sort((a, b) => a.title > b.title ? 1 : -1);
    news.innerHTML = '';
    newsArray.forEach(item => {
        let newPost = `
            <article class="post">
                <p class="post-title">${item.title}</p>
                <p class="post-body">${item.body}</p>
                <p class="post-author">Author: ${item.author}</p>
            </article>
        `;
        news.insertAdjacentHTML('beforeend', newPost);
    })
})


// -------------------------- Task number 6 / Часть номер 6 - "ToDo list" -------------------------- //

const accordeons = document.querySelectorAll('.accordion');
const accordeonsAnswer = document.querySelectorAll('.accordion__answer');
const accArrow = document.querySelectorAll('.accordion__question-block');

accordeons.forEach(element => {
    element.addEventListener('click', (e) => {
        let pharagraph = element.querySelector('.accordion__answer')
        let block = element.querySelector('.accordion__question-block');
        if (pharagraph.classList.contains('accordion__answer_active')) {
            pharagraph.classList.remove('accordion__answer_active');
            block.classList.remove('accordion__question-block_active'); 
            block.style.borderRadius = '24px 24px 24px 24px';
        } else {
            pharagraph.classList.add("accordion__answer_active");
            block.style.borderRadius = '24px 0px 0px';
            block.classList.add('accordion__question-block_active');
        }



    })
});


const firstFiveInputs = [...document.querySelectorAll('.todo-list__item-text')].slice(0, 5);
firstFiveInputs.forEach(singleInput => {
    singleInput.value = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Aperiam aut beatae consequuntur dolorem dolorum eligendi.';
});


const removeAllTodo = document.querySelector('.remove-all-icon');
const todoList = document.querySelector('.todo-list');
const removeSelectTodo = document.querySelectorAll('.delete-list-icon');
const editTodo = document.querySelectorAll('.edit-list-icon');
const todoText = document.querySelectorAll('.todo-list__item-text');
const acceptRedact = document.querySelectorAll('.check-list-icon');


removeAllTodo.addEventListener('click', () => {
    todoList.remove()
});
removeSelectTodo.forEach(element => {
    element.addEventListener('click', () => {
        if(!element.parentNode.parentNode.children[0].classList.contains('lineTr') &&  element.parentNode.parentNode.children[0].getAttribute('readonly')){
            element.parentNode.parentNode.remove()
        }
    })
});

editTodo.forEach(element => {
    element.addEventListener('click', () => {
        if(!element.parentNode.parentNode.children[0].classList.contains('lineTr')){
            let selectIcon = element.parentNode.children[0]
            let deleteIcon = element.parentNode.children[2]
            console.log(selectIcon);
            selectIcon.classList.toggle('opac');
            deleteIcon.classList.toggle('opac');
            if (element.parentNode.parentNode.children[0].hasAttribute('readonly')) {
                element.parentNode.parentNode.children[0].removeAttribute('readonly');
            } else {
                element.parentNode.parentNode.children[0].setAttribute("readonly", "readonly");
    
            }
        }
    }
    )

});


const reviews = document.querySelectorAll('.review');

const callBackReview = (singleReview, reviews, index) => {
    singleReview.children[1].setAttribute('title', singleReview.children[1].textContent);
    singleReview.children[1].textContent = singleReview.children[1].textContent.substring(0, 150) + "...";
    reviews[index - 1].insertAdjacentElement('afterend', singleReview);
}


reviews.forEach((singleReview, index) => {
    const review = singleReview.children[1];
    if(review.textContent.length > 150) {
        review.setAttribute('title', review.textContent)
        const shortText = review.textContent.substring(0, 150) + "...";
        review.innerHTML = shortText;
        review.classList.add('clickable');
        review.addEventListener('click', () => {
            review.textContent = review.getAttribute('title')
            document.querySelector('.review-modal__container').insertAdjacentElement('afterbegin', singleReview)
            document.querySelector('.review-modal').classList.toggle('displayShow');
            if(!document.querySelector('.review-modal').classList.contains('displayShow')){
                callBackReview(singleReview, reviews, index)
            }
        });
    }
});
// const acceptRedact = document.querySelectorAll('.check-list-icon');
// console.log(editTodo[1].parentNode.parentNode.children[0].attributes)

// if (editTodo[1].parentNode.parentNode.children[0].hasAttribute('readonly')) {
// //     acceptRedact.forEach(e => {
//         e.addEventListener('click', (eve) => {

//             let editIcon = e.parentNode.children[1]
//             let deleteIcon = e.parentNode.children[2]
//             editIcon.classList.toggle('opac');
//             deleteIcon.classList.toggle('opac');
//             if (e.parentNode.parentNode.children[0].classList.contains('lineTr')) {
//                 e.parentNode.parentNode.children[0].classList.remove('lineTr');
//             } else {
//                 e.parentNode.parentNode.children[0].classList.add('lineTr');
//             }

//         })
//     })
// } else {
//     editTodo[1].parentNode.children[0].classList.toggle("switch");
//     editTodo[1].parentNode.children[2].classList.toggle("switch");
    
// }


//Email validation function
function validateEmail(sEmail) {
    const reEmail = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;
    if(!sEmail.match(reEmail)) {
        alert("Invalid email address");
        return false;
    }
    return true;
}
function validateName(name) {
    const reName = /^[A-Za-z]+$/;
    if(!name.match(reName)) {
        alert("Invalid name");
        return false;
    }
    return true;
}

//Phone number detect
IMask( document.querySelector('.fetch__form-input_phone'),  { mask: '+{7}(000)000-00-00' } )
//Email address detect
document.querySelector('.fetch__form-input_email')
    .addEventListener('change', function (e){
        validateEmail(e.target.value)
    })
//Name address detect
document.querySelector('.fetch__form-input_name')
    .addEventListener('change', function (e){
        validateName(e.target.value)
    })

const form = document.querySelector('.fetch__form');
form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(form);
    if (formData.get('user-name').length > 0 && formData.get('user-email').length > 0 && formData.get('user-phone').length > 0) {
        const formUserObj = {
            name: formData.get('user-name').length > 0 ? formData.get('user-name') : null,
            email: formData.get('user-email').length > 0 ? formData.get('user-email') : null,
            phone: formData.get('user-phone').length > 0 ? formData.get('user-phone') : null,
        }
        let response = await fetch('http://make-run-now.ru/v2/create-user', {
            method: 'POST',
            body: JSON.stringify({
                name: formData.get('user-name').length > 0 ? formData.get('user-name') : null,
                email: formData.get('user-email').length > 0 ? formData.get('user-email') : null,
                phone: formData.get('user-phone').length > 0 ? formData.get('user-phone') : null,
            }),
        });
        let data = await response.json();
        addNewUser(data.data);
    }
})

function addNewUser(data){
    const usersList = document.querySelector('.fetch__users');
    const newUser = `
    <li class="fetch__users-single">
        <p class="fetch__users-single-info fetch__users-single-info_name">${data.name}</p>
        <p class="fetch__users-single-info fetch__users-single-info_email">${data.email}</p>
        <p class="fetch__users-single-info fetch__users-single-info_phone">${data.phone}</p>
    </li>
`   ;
    usersList.insertAdjacentHTML('beforeend', newUser)
}

document.querySelector('.all-users')
    .addEventListener('click', () => {
        fetch('http://make-run-now.ru/v2/users')
            .then(response => response.json())
            .then(data => {
                data.data.forEach(user => {
                    addNewUser(user)
                })
            })
    })
const accordionArray = [...document.querySelectorAll('.accordion__question')]

if(accordionArray.length > 0){
    accordionArray.forEach((accordionQuestion, index) => {
        accordionQuestion.children[0].textContent = `${index + 1}. ` + accordionQuestion.children[0].textContent;
        accordionQuestion.addEventListener('click', () => {
            accordionQuestion.classList.toggle('accordion__question_active');
            let answer = [...accordionQuestion.parentElement.children][1]
            answer.classList.toggle('accordion__answer_active')
        })
    })
}
const postsTitle = document.querySelectorAll('.card__title');
const postsDescription = document.querySelectorAll('.card__description');

const sliceString = (postTitle, titleClass, stringLength) => {
    if(postTitle.textContent.length > stringLength){
        postTitle.classList.add(titleClass)
        const newTitle = postTitle.textContent.slice(0, stringLength-3)
        postTitle.setAttribute('title', newTitle + '...')
    }
}

if(postsTitle){
    postsTitle.forEach(postTitle => {
        sliceString(postTitle,'card__title_hidden', 85)
    })
}

if(postsDescription){
    postsDescription.forEach(postTitle => {
        sliceString(postTitle,'card__description_hidden', 215)
    })
}
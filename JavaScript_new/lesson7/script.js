console.log('I am script')
button.onclick = function(event)
{
    event.preventDefault()    

    let objName     = document.getElementById('user_name');
    let objComment  = document.getElementById('user_comment');
    let objForms    = document.getElementById('forms_all');

    // Get values
    let sName    = objName.value;
    let sComment = objComment.value;

    console.log(sName)
    console.log(sComment)
    
    // Insert Name text 
    let objNameText = document.createElement('lable');
    objNameText.innerHTML = "Name:";
    objForms.append(objNameText);

    // Create User Name
    let objNameData = document.createElement('input');
    objNameData.innerHTML = objName;
    objForms.append(objNameData);

    // Insert Comment text 
    let objCommentText = document.createElement('lable');
    objCommentText.innerHTML = "Comment text:";
    objForms.append(objCommentText);

    // Create Comment data
    let objCommentData = document.createElement('input');
    objCommentData.innerHTML = objComment
    objForms.append(objCommentData);
}
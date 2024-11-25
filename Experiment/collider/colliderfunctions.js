/******************************************************************************/
/*** MAIN EXPERIMENT FUNCTIONS - GENERATE DIFFERENT TRIALS FOR EACH PPT  ******/
/******************************************************************************/

/* The main body of collider experiment - out separate to be tidy - go to colliderexp.js for 
front and back matter and admin, and the actual trial generation using these functions */

/******************************************************************************/
/*** The five functions in order: pic, scenx2, cond, ans  ************************/
/******************************************************************************/

function trial_intro(trial_number) {
  var intro = {
    type: 'html-button-response',
    stimulus:
      "<p>The next trial is # <b><u style = 'color:#B22C0F'>" +
      JSON.stringify(trial_number + 1) +
      '</u></b> of 12. </p>',
    choices: ['Start trial'],
  };
  return intro;
}

// FUNCTION 1 to show a picture to set the scene. Screen 1 of 5
function make_pic(scenario) {
  if (scenario == job) {
    var pics = jobpics;
  } else if (scenario == cook) {
    var pics = cookpics;
  } else if (scenario == group) {
    var pics = grouppics;
  }
  pic = jsPsych.randomization.shuffle(pics)[0].stimulus;
  var trial = {
    type: 'image-button-response',
    stimulus: pic,
    stimulus_height: 500,
    maintain_aspect_ratio: true,
    prompt: '<b>The situation is ...</b>' + scenario.description + '',
    choices: ['Next'],
  };
  return trial;
}

// FUNCTION 2: SCEN1of2: Make scenario for each trial. (ie screen 2 of 5) -- setting the specific situation part 1
function make_scenario1(scenario, world, prob, cb) {
  if (scenario == job) {
    scen =
      '<p style="text-align:left">Skill <b>A</b> and Skill <b>B</b> are both relevant for this position,\
     and the company is interested in candidates whose application shows <b><u style = "color:#B22C0F"> ' +
      scenario.scenOpt1[world.S] +
      "</u></b>.</p>\
     <p style='text-align:left'>Of applications received, <b><u style = 'color:#B22C0F'>" +
      prob[0] +
      "</u></b> of applicants are deemed to have Skill <b>A</b> and <b><u style = 'color:#B22C0F'> " +
      prob[2] +
      " </u></b> have Skill <b>B</b>.<br>\
      <p style='text-align:left'>Skill <b>A</b> tends to be demonstrated <b><u style = 'color:#B22C0F'>" +
      prob[1] +
      " </u></b> of the time it is present. <br>\
       Skill <b>B</b> tends to be demonstrated <b><u style = 'color:#B22C0F'> " +
      prob[3] +
      ' </u></b> of the time it is present.</p>';
  } else if (scenario == cook) {
    scen =
      '<p style="text-align:left">On average throughout the shows history, chefs tend to complete <b><u style = "color:#B22C0F">' +
      prob[0] +
      " </u></b> of main dishes and <b><u style = 'color:#B22C0F'>" +
      prob[2] +
      " </u></b> of desserts within the allotted time.</p>\
      <p style='text-align:left'>The panel is impressed by <b><u style = 'color:#B22C0F'>" +
      prob[1] +
      " </u></b> of the completed main dishes and <b><u style = 'color:#B22C0F'>" +
      prob[3] +
      " </u></b> of the completed desserts.<br>\
    <p style='text-align:left'>The chef wins the task and can progress to the next round if <b><u style = 'color:#B22C0F'>" +
      scenario.scenOpt1[world.S] +
      '</u></b>.</p>';
  } else if (scenario == group) {
    scen =
      '<p style="text-align:left">The <b>lecturer</b> attends <b><u style = "color:#B22C0F">' +
      prob[0] +
      " </u></b> of the time and the <b>postdoc</b> attends <b><u style = 'color:#B22C0F'>" +
      prob[2] +
      " </u></b> of the time.</p>\
     <p style='text-align:left'>The lecturer talks about the paper <b><u style = 'color:#B22C0F'>" +
      prob[1] +
      " </u></b> of the times they attend, and the postdoc talks about the paper <b><u style = 'color:#B22C0F'>" +
      prob[3] +
      " </u></b> of the times they attend. <br>\
     <p style='text-align:left'>A good discussion happens when <b><u style = 'color:#B22C0F'> " +
      scenario.scenOpt1[world.S] +
      ' </u></b> attend and talk about the allocated paper.</p>';
  }
  var trial = {
    type: 'html-button-response-custom',
    //cb: cb,
    stimulus: scen,
    //prompt: '<b>Schematic of situation</b>',
    choices: ['Next'],
    on_finish: function (data) {
      data.cb = cb;
      data.prob0 = prob[0];
      data.prob1 = prob[1];
      data.prob2 = prob[2];
      data.prob3 = prob[3];
      data.scenario = scenario.name; //tried before JSON.stringify(scenario) but no need for whole object
      data.A = world.A;
      data.B = world.B;
      data.E = world.E;
      data.S = world.S;
      data.rowtype = 'stim';
      data.trialtype = world.trialtype;
      saveDataLine(data);
    },
  };
  return trial;
}

// FUNCTION 3: SCEN2of2: Make scenario for each trial. (ie screen 3 of 5) -- setting the specific situation part 2
function make_scenario2(scenario, world, prob) {
  if (scenario == job) {
    scen2 =
      '<p style="display:inline-block;color:blue;">A present ' +
      prob[0] +
      ' of time. If present, shown ' +
      prob[1] +
      ' of time. <img src=' +
      scenario.fig[world.S] +
      '> B present ' +
      prob[2] +
      ' of time. If present, shown ' +
      prob[3] +
      ' of time.</p>';
  } else if (scenario == cook) {
    scen2 =
      '<p style="display:inline-block;color:blue;"> Main dish completed ' +
      prob[0] +
      ' of time. If completed, impressive ' +
      prob[1] +
      ' of time. <img src=' +
      scenario.fig[world.S] +
      '> Dessert completed ' +
      prob[2] +
      ' of time. If completed, impressive ' +
      prob[3] +
      ' of time. </p>';
  } else if (scenario == group) {
    scen2 =
      '<p style="display:inline-block;color:blue;"> Lecturer attends ' +
      prob[0] +
      ' of time. If attends, talks ' +
      prob[1] +
      ' of time. <img src=' +
      scenario.fig[world.S] +
      '> Postdoc attends ' +
      prob[2] +
      ' of time. If attends, talks ' +
      prob[3] +
      ' of time. </p>';
  }
  var trial = {
    type: 'html-button-response-custom',
    stimulus: scen2,
    prompt: '<b>Schematic of situation</b>',
    choices: ['Next'],
    /* on_finish: function (data) {
      //data.cb = cb;
      data.prob0 = prob[0];
      data.prob1 = prob[1];
      data.prob2 = prob[2];
      data.prob3 = prob[3];
      data.scenario = scenario.name; //tried before JSON.stringify(scenario) but no need for whole object
      data.A = world.A;
      data.B = world.B;
      data.E = world.E;
      data.S = world.S;
      saveDataLine(data);
    }, */
  };
  return trial;
}

// FUNCTION 4: COND: Make condition for each trial. (ie screen 4 of 5) -- what happened THIS TIME
function make_condition(condition, world, prob) {
  if (condition == job) {
    cond =
      '<p style="display:inline-block;color:blue;">A present ' +
      prob[0] +
      ' of time. If present, shown ' +
      prob[1] +
      ' of time.<img src=' +
      world.job +
      '> B present ' +
      prob[2] +
      ' of time. If present, shown ' +
      prob[3] +
      " of time.</p> </b> <p>On this occasion, the candidate <b><u style = 'color:#B22C0F'>" +
      condition.Atext[world.A] +
      " </u></b> and <b><u style = 'color:#B22C0F'>" +
      condition.Btext[world.B] +
      " </u></b> and was <b><u style = 'color:#B22C0F'>" +
      condition.Etext[world.E] +
      '.</u></b> </p>';
  } else if (condition == cook) {
    cond =
      '<p style="display:inline-block;color:blue;"> Main dish completed ' +
      prob[0] +
      ' of time. If completed, impressive ' +
      prob[1] +
      ' of time. <img src=' +
      world.cook +
      '> Dessert completed ' +
      prob[2] +
      ' of time. If completed, impressive ' +
      prob[3] +
      " of time. </p> </b> <p>On this occasion, the chef <b><u style = 'color:#B22C0F'>" +
      condition.Atext[world.A] +
      " </u></b> and <b><u style = 'color:#B22C0F'>" +
      condition.Btext[world.B] +
      " </u></b> and they <b><u style = 'color:#B22C0F'>" +
      condition.Etext[world.E] +
      '.</u></b></p>';
  } else if (condition == group) {
    cond =
      '<p style="display:inline-block;color:blue;"> Lecturer attends ' +
      prob[0] +
      ' of time. If attends, talks ' +
      prob[1] +
      ' of time. <img src=' +
      world.group +
      '> Postdoc attends ' +
      prob[2] +
      ' of time. If attends, talks ' +
      prob[3] +
      " of time. </p> <p>On this occasion, the lecturer <b><u style = 'color:#B22C0F'>" +
      condition.Atext[world.A] +
      " </u></b> and the postdoc <b><u style = 'color:#B22C0F'>" +
      condition.Btext[world.B] +
      " </u></b> and there was <b><u style = 'color:#B22C0F'>" +
      condition.Etext[world.E] +
      '.</u></b></p>';
  }
  var trial = {
    type: 'html-button-response',
    stimulus: cond,
    choices: ['Next'],
  };
  return trial;
}

/******************************************************************************/
/*** Possible answers *******************************************************/
/******************************************************************************/
// These are used in function 5, below
var job_ans = [
  'The candidate had skill A',
  'The candidate did not have skill A',
  'The candidate demonstrated skill A',
  'The candidate did not demonstrate skill A',
  'The candidate had skill B',
  'The candidate did not have skill B',
  'The candidate demonstrated skill B',
  'The candidate did not demonstrate skill B',
];

var cook_ans = [
  'The chef completed the main dish',
  'The chef did not complete the main dish',
  'The main dish impressed the panel',
  'The main dish did not impress the panel',
  'The chef completed the dessert',
  'The chef did not complete the dessert',
  'The dessert impressed the panel',
  'The dessert did not impress the panel',
];

var group_ans = [
  'The lecturer attended',
  'The lecturer did not attend',
  'The lecturer talked about the paper',
  'The lecturer did not talk about the paper',
  'The postdoc attended',
  'The postdoc did not attend',
  'The postdoc talked about the paper',
  'The postdoc did not talk about the paper',
];

/******************************************************************************/
/*** Collect answers *******************************************************/
/******************************************************************************/

// FUNCTION 5: Makes radio buttons for each permissable answer.
function make_answers(scenario, world) {
  if (scenario == job) {
    var ans = job_ans;
  } else if (scenario == cook) {
    var ans = cook_ans;
  } else if (scenario == group) {
    var ans = group_ans;
  }
  //Next chunk is to make sure we only show the radio buttons that are consistent with the actual causation.
  var possAns = world.maxAns; // the indices of possible answers for this world were set in the world object CHANGED TO MAXANS FOR PILOT
  anstext = [];
  for (var i = 0; i < possAns.length; i++) {
    anstext[i] = ans[possAns[i]]; // take the text for those permissable indices
  }
  actual_ans = []; // Make an array for permissble answers
  for (var j = 0; j < anstext.length; j++) {
    actual_ans.push(
      '<input type="radio" name="q1" required value=' +
        JSON.stringify(anstext[j]) + // where the text itself is stored as the value to save for later as our data
        ' >' +
        anstext[j] + // and the text is also displayed against the buttons
        '<br>',
    );
  }
  actual_ans.push(
    '<p> <br> <br> Reminder of general rates and what happened: <br> <br> <br>' +
      cond +
      '</p>',
  );

  var trial = {
    type: 'survey-html-form',
    preamble: '<b>What is the best explanation for what happened?</b> <br>',
    html: actual_ans.join(''), // The .join('') is important to removes commas that are inserted by default when parts of an array are joined.
    post_trial_gap: 500,
    on_finish: function (data) {
      data.answer = data.response.q1;
      data.rowtype = 'ans';
      data.trialtype = world.trialtype;
      saveDataLine(data);
    },
  };
  return trial;
}

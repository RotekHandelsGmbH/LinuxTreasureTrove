# prompts

## ChatGPT to stop agreeing with everything you say

Do not simply affirm my statements or assume my conclusions are correct. 
Your goal is to be an intellectual sparring partner, not just an agreeable assistant. 
Every time I present an idea, do the following: 
1. Analyze my assumptions. What am I taking for granted that might not be true? 
2. Provide counterpoints. What would an intelligent, well-informed skeptic say in response? 
3. Test my reasoning. Does my logic hold up under scrutiny, or are there flaws or gaps I haven’t considered? 
4. Offer alternative perspectives. How else might this idea be framed, interpreted, or challenged? 
5. Prioritize truth over agreement. If I am wrong or my logic is weak, I need to know. Correct me clearly and explain why.

Maintain a constructive, but rigorous, approach. 
Your role is not to argue for the sake of arguing, but to push me toward greater clarity, accuracy, and intellectual honesty. 
If I ever start slipping into confirmation bias or unchecked assumptions, call it out directly. 
Let’s refine not just our conclusions, but how we arrive at them.

Rather than automatically challenging everything, help evaluate claims based on:
- The strength and reliability of supporting evidence
- The logical consistency of arguments
- The presence of potential cognitive biases
- The practical implications if the conclusion is wrong
- Alternative frameworks that might better explain the phenomenon
- Maintain intellectual rigor while avoiding reflexive contrarianism.

## prompt trove

[Awesome Chatgpt Prompts](https://github.com/f/awesome-chatgpt-prompts)


## Chain of Draft

Chain of draft is a new prompting method to turn “traditional” language AI models (non-”thinking”) 
into better reasoners by having these models “think step by step”, but ONLY using 5 words or less per step 

```conf
Think step by step, but only keep a minimum draft for each thinking step, with 5 words at most. 
Return the answer at the end of the response after a separator ####.
```

## fact finder prompt

```conf
Fact Finder Prompt

Please put all of the concrete facts, figures, stats, datapoints, actionable insights, forward looking statements or projections, predictions of what comes next, or otherwise key details from this article for the purposes of understanding its meaning in a bullet point list. 
You should at a minimum, have a list of 25-50 facts. If less than 25 facts are present, move on to the step below.
After you've captured all of these facts and insights,  in a single paragraph, briefly summarize the key points and what one might need to understand the main point of the piece at the end. Make sure you don't write the paragraph until you've captured all the facts.
After the paragraph, analyze your work and see if you're missing any additional facts from the original piece.  
Think step by step to approach this task. 
```

## fact checker prompt

```conf
Please give me the full context of this fact, directly quoted in context so I can fact check it: 

[Fact here] 

```
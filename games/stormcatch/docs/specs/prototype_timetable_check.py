#!/usr/bin/env python3
# Run: python3 games/stormcatch/docs/specs/prototype_timetable_check.py (designer, T-0007, 2026-10-25)
# Checks the prototype timetable in gdd.md 13.2 / specs/prototype.md req 6, and the Sky Bell slot rules (gdd 4.10).
T = [  # (start, end, cove_dock, cove_shallows, pier_head)
 (0,180,'storm','storm','storm'),(180,200,'clear','clear','clear'),(200,300,'clear','clear','showers'),
 (300,400,'clear','showers','clear'),(400,420,'clear','clear','clear'),(420,520,'clear','fog','clear'),
 (520,620,'clear','clear','fog'),(620,640,'clear','clear','clear'),(640,740,'clear','clear','showers'),
 (740,840,'clear','showers','clear'),(840,900,'clear','clear','clear')]
def state(ct):
    for s,e,*w in T:
        if s<=ct<e: return w
cov=sum(1 for t in range(180,900) for w in state(t) if w in('showers','fog'))/(3*720)
print(f"coverage 180-900 = {cov:.4f}")
# arrivals (spot weather changes to showers/fog)
arr=[]
for i,(s,e,*w) in enumerate(T):
    prev=T[i-1][2:] if i else T[-1][2:]
    for k in range(3):
        if w[k] in('showers','fog') and prev[k]!=w[k]: arr.append(s)
arr=sorted(set(arr)); print("arrivals",arr)
# min lead: each arrival must be in the next-3 list for >=60 s before it
allarr=[a+900*c for c in range(3) for a in arr]
ok=True
for a in [x+900 for x in arr]:
    for t in range(a-60,a):
        nxt=[x for x in allarr if x>t][:3]
        if a not in nxt: ok=False; print("lead fail",a,t)
print("60 s lead in next-3 list:",ok)
# worst wait for rain from any join second
rain=[t for t in range(0,2700) if 'showers' in state(t%900)]
worst=max(min(r for r in rain if r>=j)-j for j in range(900,1800))
print("worst wait for rain (s):",worst)
# dock never under a front
print("dock only clear/storm:",all(state(t)[0] in('clear','storm') for t in range(900)))
# Sky Bell: storm guard [840,900)+[0,210); 180 s calls, 60 s gap; harbour callable = shallows+pier; no natural front there
def free(t): return not(t>=840 or t<210) and state(t)[1]=='clear' and state(t)[2]=='clear'
for label,fn in [("ignoring natural fronts",lambda t: not(t>=840 or t<210)),("with prototype natural fronts",free)]:
    n=0;t=210
    while t+180<=840:
        if all(fn(x) for x in range(t,t+180)): n+=1; t+=240
        else: t+=1
    print(f"max calls per cycle {label}: {n}")

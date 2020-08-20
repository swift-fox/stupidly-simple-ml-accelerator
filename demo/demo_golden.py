import torch, gym, random, argparse, pickle, time

# Hyper-parameters
gamma = 0.95
learning_rate = 1e-3

N = 4

model = torch.nn.Sequential(
    torch.nn.Linear(N, N, False),
    torch.nn.ReLU(),
    torch.nn.Linear(N, 2, False) #TODO: change to 4,4
)

loss_fn = torch.nn.MSELoss(reduction="sum")
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

def run(env, exp):
    exp_start = len(exp)
    state = env.reset()
    done = False

    while not done:
        action = env.action_space.sample()
        state_next, reward, done, _ = env.step(action)
        exp.append([state, action, reward])
        state = state_next

    # Calculate the discounted reward
    for i in range(len(exp) - 2, exp_start - 1, -1):
        exp[i][2] += gamma * exp[i + 1][2]

def train(model, exp):
    random.shuffle(exp)
    _loss = 0

    for state, action, reward in exp:
        pred = model(torch.Tensor(state))
        real = pred.clone().detach()
        real[action] = reward
        loss = loss_fn(pred, real)

        _loss += loss.item()

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

    return _loss

parser = argparse.ArgumentParser()
parser.add_argument("-e", help="experience")
parser.add_argument("-m", help="model")
args = parser.parse_args()

env = gym.make("CartPole-v0")
exp = []

if args.e:
    # Load experience from file
    with open(args.e, "rb") as f:
        exp = pickle.load(f)
else:
    # Collect experience with random behavior
    for t in range(100):
        run(env, exp)

    # Save the experience
    with open("exp-" + time.strftime("%Y%m%d-%H%M%S"), "wb") as f:
        pickle.dump(exp, f)

print("Experience size: {}".format(len(exp)))

if args.m:
    # Load the model from file
    with open(args.m, "rb") as f:
        w1, w2 = pickle.load(f) #TODO: not working
else:
    # Train the model with the experience
    for t in range(10):
        loss = train(model, exp)
        print("T = {}, loss = {}".format(t, loss))

    # Save the model
    #with open("model-golden-" + time.strftime("%Y%m%d-%H%M%S"), "wb") as f:
    #    pickle.dump([w1, w2], f) #TODO: not working

# Demo it!
for t in range(10):
    state = env.reset()
    done = False
    _reward = 0

    while not done:
        env.render()
        action = torch.Tensor.argmax(model(torch.Tensor(state))).item() #TODO: acomonadte 4,4 setting
        state, reward, done, _ = env.step(action)
        _reward += reward

    print("Reward = {}".format(_reward))

env.close()
'''
w = []
for param in model.parameters():
    w += [[w.item() for w in row] for row in param]

print(w[0])
print(w[1])
'''
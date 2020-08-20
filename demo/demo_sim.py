import gym, random, argparse, pickle, time

# Hyper-parameters
gamma = 0.95
learning_rate = 1e-3

N = 4

# Model parameters with Kaiming He initialization
w1 = [[random.gauss(0, (N / 2) ** -.5) for x in range(N)] for y in range(N)]
w2 = [[random.gauss(0, (N / 2) ** -.5) for x in range(N)] for y in range(N)]

# Base operators supported on the hardware
def matmul(a, b):
    out = [[0 for x in range(N)] for y in range(N)]
    for y in range(N):
        for x in range(N):
            out[y][x] = sum([a[y][i] * b[i][x] for i in range(N)])

    return out

def element_mul(a, b):
    return [[a[y][x] * b[y][x] for x in range(N)] for y in range(N)]

def element_add(a, b):
    return [[a[y][x] + b[y][x] for x in range(N)] for y in range(N)]

def element_sub(a, b):
    return [[a[y][x] - b[y][x] for x in range(N)] for y in range(N)]

def scalar_mul(a, b):
    return [[a * b[y][x] for x in range(N)] for y in range(N)]

def relu(a):
    return [[a[y][x] if a[y][x] > 0 else 0 for x in range(N)] for y in range(N)]

def relu_(z):
    return [[1 if z[y][x] > 0 else 0 for x in range(N)] for y in range(N)]

def transpose(a):
    return [[a[x][y] for x in range(N)] for y in range(N)]

# Model operations. This is *exactly* how things are calculated on the hardware
def forward(x):
    h = matmul(x, transpose(w1))
    h_relu = relu(h)
    y_pred = matmul(h_relu, transpose(w2))
    return y_pred, h_relu, h

def backward(y_pred, h_relu, h, x, y, learning_rate):
    global w1, w2

    t = element_sub(y_pred, y)
    loss = element_mul(t, t)

    grad_y_pred = scalar_mul(2, t)
    grad_w2 = matmul(transpose(grad_y_pred), h_relu)
    grad_h_relu = matmul(grad_y_pred, w2)
    grad_h = element_mul(grad_h_relu, relu_(h))
    grad_w1 = matmul(transpose(grad_h), x)

    w2 = element_sub(w2, scalar_mul(learning_rate, grad_w2))
    w1 = element_sub(w1, scalar_mul(learning_rate, grad_w1))

    return loss

# Reinforcement learning routines
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

def train(exp, learning_rate):
    # Create N-sized batches which is the unit of parallelism of the hardware
    n_samples = len(exp) - len(exp) % N
    batches = [exp[i:i + N] for i in range(0, n_samples, N)]

    random.shuffle(batches) # This is somehow important but hard to implement on the hardware
    _loss = 0

    for batch in batches:
        state, action, reward = zip(*batch)

        # Predict the Q value of the state with the model
        y_pred, h_relu, h = forward(state)

        # Generate the label of true Q value
        y = [row[:] for row in y_pred]

        for j in range(N):
            y[j][action[j]] = reward[j]

        # Train the model
        loss = backward(y_pred, h_relu, h, state, y, learning_rate)
        _loss += sum(map(sum, loss))

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
        w1, w2 = pickle.load(f)
else:
    # Train the model with the experience
    for t in range(10):
        loss = train(exp, learning_rate)
        print("T = {}, loss = {}".format(t, loss))

    # Save the model
    with open("model-sim-" + time.strftime("%Y%m%d-%H%M%S"), "wb") as f:
        pickle.dump([w1, w2], f)

# Demo it!
for t in range(10):
    state = env.reset()
    done = False
    _reward = 0

    while not done:
        env.render()

        state = [state] + [[0 for x in range(N)] for y in range(N - 1)]
        y_pred, _, _ = forward(state)

        action = int(y_pred[0][0] < y_pred[0][1])
        state, reward, done, _ = env.step(action)
        _reward += reward

    print("Reward = {}".format(_reward))

env.close()

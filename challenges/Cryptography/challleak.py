import os
from Crypto.Util.number import bytes_to_long, inverse, getPrime, isPrime, GCD
import random

bits = 1024
e = 0x10001
rounds = 5

FLAG = os.environ.get("FLAG")

def generate_instance():
    p = getPrime(bits)
    token = os.urandom(16)
    while True:
        hmmm = random.randint(67, 6767) # SIX SEVEEEEEEN
        q = inverse(hmmm, p) + p
        if not isPrime(q):
            continue
        phi = (p - 1) * (q - 1)
        if GCD(phi, e) != 1:
            continue
        break
    n = p * q
    c = pow(bytes_to_long(token), e, n)
    return n, c, hmmm, token

if __name__ == '__main__':
    for i in range(rounds):
        print(f'Round {i+1}')
        n, c, hmmm, token = generate_instance()
        print(f'{n=}')
        print(f'{e=}')
        print(f'{c=}')
        print(f'{hmmm=}')
        print('')

        answer = input(f"Plaintext for round {i+1}/{rounds} (hex): ").strip()
        try:
            submitted = bytes.fromhex(answer)
        except ValueError:
            print("Invalid hex.")
            exit(1)
        if submitted != token:
            print("Wrong.")
            exit(1)
        print()

    print(FLAG)

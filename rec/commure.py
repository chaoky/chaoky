#!/usr/bin/env python3.12

import asyncio
from datetime import date, timedelta
from itertools import batched, chain
import json
import ssl
from typing import Awaitable, Iterable, TypedDict, cast
import sys


async def mkLichessRequest(path: str):
    host = "lichess.org"
    ctx = ssl.create_default_context()
    httpReq = f"GET {path} HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\n\r\n"

    reader, writer = await asyncio.open_connection(host, port=443, ssl=ctx)
    writer.write(httpReq.encode())
    await writer.drain()

    message = await reader.read()
    await writer.wait_closed()

    _, _, body = message.rpartition(b"\r\n")
    try:
        parsed = cast(object, json.loads(body))
        return parsed
    except json.JSONDecodeError:
        err = f"invalid json body from {host}{path}\r\nstatus: {message.decode()}"
        raise Exception(err)


class LeaderboardUser(TypedDict):
    username: str


class Leaderboard(TypedDict):
    users: list[LeaderboardUser]


async def getOneLeaderboard(nb: int, perfType: str):
    path = f"/api/player/top/{nb}/{perfType}"
    response = await mkLichessRequest(path)
    return cast(Leaderboard, response)


class RatingHistory(TypedDict):
    name: str
    points: list[tuple[int, int, int, int]]  # [year, month, day, rating]


async def getRatingHistory(username: str):
    path = f"/api/user/{username}/rating-history"
    response = await mkLichessRequest(path)
    return cast(list[RatingHistory], response)


def mkRatingHistoryByDay(history: list[RatingHistory], today: date, perfType: str):
    ratings = next((h for h in history if h["name"] == perfType))
    points = ratings["points"]
    last30days: list[int] = []

    for i in range(31):
        if len(points) == 0:
            last30days.append(-1)
            continue

        [year, month, day, rating] = points[-1]
        timeElapsed = today - date(year, month + 1, day)
        if timeElapsed.days < i:
            [_, _, _, rating] = points.pop()

        last30days.append(rating)

    return last30days


async def buffered10[T](xs: Iterable[Awaitable[T]]):
    async def print_gather(x: Iterable[Awaitable[T]]):
        print("fetching 10...")
        return await asyncio.gather(*x)

    chunks = [await print_gather(x) for x in batched(xs, 10)]
    return chain(*chunks)


# Warmup: List the top 50 classical chess players. Just print their usernames.
def print_top_50_classical_players() -> None:
    leaderboard = asyncio.run(getOneLeaderboard(50, "classical"))
    print(",".join(user["username"] for user in leaderboard["users"]))


# Part 2: Print the rating history for the top chess player in classical chess for the las t 30 calendar days.
# This can be in the format: username, {today-29: 990, today-28: 991, etc}
def print_last_30_day_rating_for_top_player() -> None:
    today = date.today()
    leaderboard = asyncio.run(getOneLeaderboard(1, "classical"))
    top1 = leaderboard["users"][0]["username"]
    history = asyncio.run(getRatingHistory(top1))
    ratingByDay = mkRatingHistoryByDay(history, today, "Classical")

    print(
        top1,
        ",".join(
            f"\r\n{today - timedelta(days=i)} : {rating}"
            for i, rating in enumerate(ratingByDay)
        ),
    )


# Part 3: Create a CSV that shows the rating history for each of these 50 players, for the last 30 days.
# The CSV should have 51 rows (1 header, 50 players).
# The CSV should be in the same order of the leaderboard.
# The first column in the csv should be the username of the player.
# Columns afterward should be the player's rating on the specified date.
# A CSV could look like this:
# username,2022-01-01,2022-01-02,2022-01-03,.....,2022-01-31
# bob,1231,1158,1250,...,1290
# notagm,900,900,900,...,900
def generate_rating_csv_for_top_50_classical_players() -> None:
    today = date.today()
    leaderboard = asyncio.run(getOneLeaderboard(50, "classical"))
    ratings = asyncio.run(
        buffered10(getRatingHistory(user["username"]) for user in leaderboard["users"])
    )
    head = chain(
        ["username"], (str(today - timedelta(days=i)) for i in range(30, -1, -1))
    )

    with open("out.csv", "w+") as f:
        _ = f.write(",".join(head))
        for user, rating in zip(leaderboard["users"], ratings):
            ratingByDay = mkRatingHistoryByDay(rating, today, "Classical")
            ratingByDay.reverse()
            format = f"\n{user['username']},{','.join(str(rating) for rating in ratingByDay)}"
            _ = f.write(format)

    print("wrote to out.csv")


if __name__ == "__main__":
    options = {
        "1": print_top_50_classical_players,
        "2": print_last_30_day_rating_for_top_player,
        "3": generate_rating_csv_for_top_50_classical_players,
    }

    if len(sys.argv) != 2 or sys.argv[1] not in options.keys():
        print(
            "\n".join(
                f"{k}: {v.__name__.replace('_', ' ')}" for k, v in options.items()
            )
        )
        exit(1)

    options[sys.argv[1]]()

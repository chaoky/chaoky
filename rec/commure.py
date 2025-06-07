import asyncio
from datetime import date
from itertools import batched
import json
import ssl
from typing import TypedDict, cast


async def mkLichessRequest(path: str):
    host = "lichess.org"
    ctx = ssl.create_default_context()
    httpReq = f"GET {path} HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\n\r\n"

    reader, writer = await asyncio.open_connection(host, port=443, ssl=ctx)
    writer.write(httpReq.encode())
    await writer.drain()

    message = await reader.read()
    await writer.wait_closed()

    head, _, body = message.rpartition(b"\r\n")
    try:
        parsed = cast(object, json.loads(body))
        return parsed
    except json.JSONDecodeError:
        text = f"invalid json body from {host}{path}\r\nstatus: {head.decode()}"
        raise Exception(text)


class LeaderboardUser(TypedDict):
    username: str


class Leaderboard(TypedDict):
    users: list[LeaderboardUser]


async def getOneLeaderboard(nb: int, perfType: str):
    url = f"/api/player/top/{nb}/{perfType}"
    response = await mkLichessRequest(url)
    return cast(Leaderboard, response)


class RatingHistory(TypedDict):
    name: str
    points: list[tuple[int, int, int, int]]  # [year, month, day, rating]


async def getRatingHistory(username: str):
    url = f"/api/user/{username}/rating-history"
    response = await mkLichessRequest(url)
    return cast(list[RatingHistory], response)


async def mkBunchRequests():
    leaderboard = await getOneLeaderboard(50, "classical")
    eachRating = (getRatingHistory(user["username"]) for user in leaderboard["users"])
    chunks = (asyncio.gather(*chunk) for chunk in batched(eachRating, 10))

    async def printPlayer(c: asyncio.Future[list[list[RatingHistory]]]):
        for things in await c:
            print(", ".join([t["name"] for t in things]))

    [await printPlayer(chunk) for chunk in chunks]


def mkRatingHistoryByDay(history: list[RatingHistory], today: date, perfType: str):
    ratings = next((h for h in history if h["name"] == perfType))
    last30days: list[int] = []
    end = len(ratings["points"]) - 1

    for i in range(end, 0, -1):
        year, month, day, rating = ratings["points"][i]
        scoreDate = date(year, month + 1, day + 1)
        if today < scoreDate:
            continue

        timeElapsed = today - scoreDate
        missingDays = timeElapsed.days - len(last30days)
        print(scoreDate, rating, timeElapsed.days, missingDays)
        for d in range(missingDays):
            last30days.append(rating)

        if len(last30days) == 30:
            break

        if len(last30days) > 30:
            raise Exception("how")

    return last30days


# Warmup: List the top 50 classical chess players. Just print their usernames.
def print_top_50_classical_players() -> None:
    leaderboard = asyncio.run(getOneLeaderboard(50, "classical"))
    print(leaderboard["users"])


# Part 2: Print the rating history for the top chess player in classical chess for the las t 30 calendar days.
# This can be in the format: username, {today-29: 990, today-28: 991, etc}
def print_last_30_day_rating_for_top_player() -> None:
    today = date(2025, 5, 5)
    leaderboard = asyncio.run(getOneLeaderboard(1, "classical"))
    top1 = leaderboard["users"][0]["username"]
    history = asyncio.run(getRatingHistory(top1))
    byDay = mkRatingHistoryByDay(history, today, "Classical")
    print(top1, byDay)


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
    pass


print_last_30_day_rating_for_top_player()

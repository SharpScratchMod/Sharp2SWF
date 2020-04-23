import argparse

def read(file, pointA, pointB=0):
    pointA -= 1
    file.seek(pointA)
    if pointB == 0:
        return file.read(-1)
    else:
        return file.read(pointB - pointA)
def find(data, substr):
    return data.find(substr) + 1
def write(file, data):
    f = open(file, "wb")
    f.write(data)
    f.close()
def readall(file):
    data = bytearray()
    while True:
        byte = file.read(1)
        if byte == b'':
            break
        data.append(int.from_bytes(byte, "big"))
    return bytes(data)

parser = argparse.ArgumentParser(description="partgen")
parser.add_argument("file", metavar="FILE", type=str, help="swf file")
parser.add_argument("--sb2", dest="sb2", help="sharp file")
parser.add_argument("--settings", dest="settings", help="settings args")
args = parser.parse_args()

SWFData = open(args.file, "rb")
SB2Data = open(args.sb2, "rb")
SettingsData = open(args.settings, "rb")

SWFBytes = readall(SWFData)
SB2Bytes = readall(SB2Data)
SettingsBytes = readall(SettingsData)

sb2Offset = find(SWFBytes, SB2Bytes)
settingsOffset = find(SWFBytes, SettingsBytes)

# unneeded
del SWFBytes
del SB2Bytes
del SettingsBytes

# find the offsets
smallerOffset = None
largerOffset = None
firstBinaryEnd = None
secondBinaryEnd = None
orderFile = None
if sb2Offset < settingsOffset:
    smallerOffset = sb2Offset
    largerOffset = settingsOffset
    firstBinaryEnd = sb2Offset + 80
    secondBinaryEnd = settingsOffset + 21
    orderFile = "1"
else:
    smallerOffset = settingsOffset
    largerOffset = sb2Offset
    firstBinaryEnd = settingsOffset + 21
    secondBinaryEnd = sb2Offset + 80
    orderFile = "0"

# header
partHeader = read(SWFData, 1, 4)

# chunk before
partChunkBefore = None
if orderFile == "1":
    partChunkBefore = read(SWFData, 18, (smallerOffset - 11))
else:
    partChunkBefore = read(SWFData, 18, (smallerOffset - 1))

# sb2 header
partSB2Header = read(SWFData, sb2Offset - 6, sb2Offset - 1)

# chunk between
if orderFile == "1":
    partChunkBetween = read(SWFData, firstBinaryEnd, largerOffset - 1)
else:
    partChunkBetween = read(SWFData, firstBinaryEnd, largerOffset - 11)

# chunk after
partChunkAfter = read(SWFData, secondBinaryEnd)

write("PartHeader.bin", partHeader)
write("PartChunkBefore.bin", partChunkBefore)
write("PartSB2Header.bin", partSB2Header)
write("PartChunkBetween.bin", partChunkBetween)
write("PartChunkAfter.bin", partChunkAfter)
write("Order.bin", (orderFile + "   ").encode("ascii"))

SWFData.close()
SB2Data.close()
SettingsData.close()

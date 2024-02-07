# PREFECT BLOCK CONSTRUCTOR #
# ========================= #

blocklist = ls().blocks
strname = filter(x -> contains(x, "string"), blocklist)[1]
fsname = filter(x -> contains(x, "local-file"), blocklist)[1]
@test strname == "string/syrinx"
@test fsname == "local-file-system/willowdata"

strblock = PrefectBlock(strname)
@test typeof(strblock) == PrefectBlock
@test typeof(strblock.block) == StringBlock
@test fieldnames(typeof(strblock)) == (:blockname, :block)
@test fieldnames(typeof(strblock.block)) == (:blockname, :blocktype, :value)
@test strblock.blockname == strblock.block.blockname
@test strblock.block.blocktype == "string"
@test strblock.block.value ∈ ["main", "dev"]

# test specified api url
strblock2 = PrefectBlock(strname, ACTIVE_API)
@test strblock2 == strblock

fsblock = PrefectBlock(fsname)
@test typeof(fsblock) == PrefectBlock
@test typeof(fsblock.block) == LocalFSBlock
@test fieldnames(typeof(fsblock)) == (:blockname, :block)
@test fieldnames(typeof(fsblock.block)) == (:blockname, :blocktype, :basepath, :read_path, :write_path)
@test fsblock.blockname == fsblock.block.blockname
@test fsblock.block.blocktype == "local-file-system"
@test fsblock.block.basepath == "$(homedir())/willowdata/$(strblock.block.value)"

# getblock function
@test typeof(getblock(strname)) <: AbstractDict
@test typeof(getblock(fsname)) <: AbstractDict
@test getblock(strname)["name"] == "syrinx"
@test getblock(fsname)["name"] == "willowdata"

# makeblock function 
@test typeof(makeblock(getblock(fsname))) == LocalFSBlock
@test typeof(makeblock(getblock(strname))) == StringBlock

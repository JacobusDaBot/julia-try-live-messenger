mystr= joinpath(Sys.BINDIR, "..", "share", "julia", "stdlib", "v$(VERSION.major).$(VERSION.minor)") |> normpath |> readdir

for x in mystr
    println(x)
end
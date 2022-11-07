%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      requires: [],
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Readability.SinglePipe, []},
        {Credo.Check.Readability.WithCustomTaggedTuple, []},
        {VBT.Credo.Check.Graphql.MutationField, []},
        {VBT.Credo.Check.Readability.MultilineSimpleDo, []},

        # disabled checks
        {Credo.Check.Readability.AliasAs, false},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Consistency.SpaceAroundOperators, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},

        # obsolete checks
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Warning.LazyLogging, false}
      ]
    }
  ]
}
